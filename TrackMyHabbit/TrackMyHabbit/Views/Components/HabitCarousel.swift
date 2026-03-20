import SwiftUI
import SwiftData
import UIKit

struct HabitCarousel: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habit: Habit
    @State private var days: [String] = DateUtils.generateDays(count: 7)

    private let cardWidth: CGFloat = 288
    private let cardHeight: CGFloat = 397
    private let cardSpacing: CGFloat = 20

    @State private var scrollTarget: String?

    private var cardSelectionAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.86)
    }

    var body: some View {
        GeometryReader { geometry in
            let horizontalInset = max((geometry.size.width - cardWidth) / 2, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(days.reversed(), id: \.self) { dateStr in
                        let isActive = (scrollTarget == dateStr)
                        let entry = habit.entries.first(where: { $0.dateString == dateStr })

                        DayCard(
                            dateStr: dateStr,
                            entry: entry,
                            isActive: isActive,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            tapAction: {
                                withAnimation(cardSelectionAnimation) {
                                    scrollTarget = dateStr
                                }
                            },
                            onImagePicked: { data in
                                saveImage(data, for: dateStr, existingEntry: entry)
                            }
                        )
                        .scaleEffect(isActive ? 1.0 : 0.92)
                        .opacity(isActive ? 1.0 : 0.5)
                        .animation(cardSelectionAnimation, value: isActive)
                        .frame(width: cardWidth, height: cardHeight)
                        .zIndex(isActive ? 1 : 0)
                    }
                }
                .padding(.vertical, 80)
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollTarget, anchor: .center)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
            .contentMargins(.horizontal, horizontalInset, for: .scrollContent)
            .scrollClipDisabled()
            .onAppear {
                refreshDaysIfNeeded()
                if scrollTarget == nil {
                    scrollTarget = days.reversed().first
                }
            }
        }
        .frame(height: cardHeight + 160)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            refreshDaysIfNeeded()
        }
    }

    private func saveImage(_ data: Data, for dateString: String, existingEntry: HabitEntry?) {
        // Re-resolve the entry at save time to avoid inserting duplicates if the caller's
        // `existingEntry` is stale.
        let resolvedEntry = existingEntry ?? resolveEntry(for: dateString)

        do {
            let fileURL = try storeImage(data, for: dateString)

            do {
                if let resolvedEntry {
                    resolvedEntry.imageUri = fileURL.absoluteString
                } else {
                    let newEntry = HabitEntry(
                        dateString: dateString,
                        imageUri: fileURL.absoluteString,
                        habit: habit
                    )
                    modelContext.insert(newEntry)
                }

                try modelContext.save()
            } catch {
                // Roll back the file write if the database save fails.
                try? FileManager.default.removeItem(at: fileURL)
                throw error
            }
        } catch {
            print("Failed to save image for \(dateString): \(error.localizedDescription)")
        }
    }

    private func resolveEntry(for dateString: String) -> HabitEntry? {
        // Prefer an explicit fetch so we don't rely on relationship freshness.
        do {
            let habitId = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitId
            }
            var descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            descriptor.fetchLimit = 2
            let results = try modelContext.fetch(descriptor)
            if results.count > 1 {
                // Best-effort de-dupe: keep the first, delete the rest.
                for dup in results.dropFirst() {
                    modelContext.delete(dup)
                }
                try? modelContext.save()
            }
            return results.first
        } catch {
            // Fall back to relationship data if fetch fails for any reason.
            return habit.entries.first(where: { $0.dateString == dateString })
        }
    }

    private func refreshDaysIfNeeded() {
        let newDays = DateUtils.generateDays(count: 7)
        guard newDays != days else { return }
        days = newDays
        // If the current target is outside the new window, snap back to newest day.
        if let target = scrollTarget, !newDays.contains(target) {
            scrollTarget = newDays.reversed().first
        }
        if scrollTarget == nil {
            scrollTarget = newDays.reversed().first
        }
    }

    private func storeImage(_ data: Data, for dateString: String) throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habit.id.uuidString, isDirectory: true)

        try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)

        let fileURL = photoDirectory.appendingPathComponent("\(dateString).jpg")
        let encodedData = normalizedJPEGData(from: data) ?? data
        try encodedData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    private func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        return image.jpegData(compressionQuality: 0.9)
    }
}
