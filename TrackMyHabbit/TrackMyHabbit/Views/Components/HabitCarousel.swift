import SwiftUI
import SwiftData
import UIKit

struct HabitCarousel: View {
    @Environment(\.modelContext) private var modelContext

    let habit: Habit
    @State private var days: [String] = DateUtils.generateDays(count: 7)
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = 288
    private let cardHeight: CGFloat = 397
    private let scaleStep: CGFloat = 0.9
    private let cardStep: CGFloat = 47 // cardWidth + HStack spacing (-241) from Figma
    private let maxVisibleBehind: Int = 2
    private let swipeThreshold: CGFloat = 60
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let leftPeekFromEdge: CGFloat = 12

    /// Days ordered from newest (today) to oldest.
    private var orderedDays: [String] {
        days.sorted(by: >)
    }

    var body: some View {
        ZStack {
            ForEach(visibleIndices, id: \.self) { index in
                let depth = index - currentIndex
                cardLayer(at: index, depth: depth)
            }
        }
        .offset(x: centeringOffset)
        .frame(height: cardHeight + 160)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .padding(.horizontal, 20)
        .onAppear {
            refreshDaysIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            refreshDaysIfNeeded()
        }
    }

    // MARK: - Centering

    /// Shifts the stack left to visually center the active card + back cards group,
    /// clamped so the active card keeps at least 20pt from the screen edge.
    private var centeringOffset: CGFloat {
        let behindCount = CGFloat(min(maxVisibleBehind, max(0, orderedDays.count - 1 - currentIndex)))
        guard behindCount > 0 else { return 0 }
        let deepestScale = pow(scaleStep, behindCount)
        let deepestRightEdge = behindCount * cardStep + (cardWidth * deepestScale) / 2
        let activeRightEdge = cardWidth / 2
        let idealOffset = -(deepestRightEdge - activeRightEdge) / 2
        let maxLeftShift = -(screenWidth / 2 - cardWidth / 2 - 20)
        return max(idealOffset, maxLeftShift)
    }

    // MARK: - Visible indices

    /// Indices of visible cards, ordered back-to-front for ZStack layering.
    private var visibleIndices: [Int] {
        let start = max(0, currentIndex - 1)
        let end = min(orderedDays.count, currentIndex + maxVisibleBehind + 1)
        guard start < end else { return [] }
        return Array((start..<end).reversed())
    }

    // MARK: - Card layer

    @ViewBuilder
    private func cardLayer(at index: Int, depth: Int) -> some View {
        let dateStr = orderedDays[index]
        let isActive = depth == 0
        let entry = habit.entries.first(where: { $0.dateString == dateStr })

        let leftProgress: CGFloat = dragOffset < 0
            ? min(-dragOffset / (cardWidth * 0.5), 1.0)
            : 0
        let rightProgress: CGFloat = dragOffset > 0
            ? min(dragOffset / (cardWidth * 0.5), 1.0)
            : 0

        let scale = cardScale(depth: depth, leftProgress: leftProgress, rightProgress: rightProgress)
        let xOffset = cardXOffset(depth: depth, leftProgress: leftProgress, rightProgress: rightProgress)

        DayCard(
            dateStr: dateStr,
            entry: entry,
            isActive: isActive,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            tapAction: {},
            onImagePicked: { data in
                saveImage(data, for: dateStr, existingEntry: entry)
            }
        )
        .scaleEffect(scale, anchor: .center)
        .offset(x: xOffset)
        .zIndex(depth < 0 ? 150 : (depth == 0 ? 100 : Double(50 - depth)))
        .allowsHitTesting(isActive)
    }

    // MARK: - Card positioning

    private func cardScale(depth: Int, leftProgress: CGFloat, rightProgress: CGFloat) -> CGFloat {
        if depth <= 0 { return 1.0 }
        let base = pow(scaleStep, CGFloat(depth))
        let target = pow(scaleStep, CGFloat(depth - 1))
        return base + (target - base) * leftProgress
    }

    private func cardXOffset(depth: Int, leftProgress: CGFloat, rightProgress: CGFloat) -> CGFloat {
        if depth == 0 {
            return dragOffset
        }
        if depth < 0 {
            let baseOffset = -(screenWidth / 2) + leftPeekFromEdge - cardWidth / 2
            return baseOffset + (0 - baseOffset) * rightProgress
        }
        let baseOffset = CGFloat(depth) * cardStep
        let targetOffset = CGFloat(depth - 1) * cardStep
        return baseOffset + (targetOffset - baseOffset) * leftProgress
    }

    // MARK: - Swipe gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                let t = value.translation.width
                if t < 0 && currentIndex < orderedDays.count - 1 {
                    dragOffset = t
                } else if t > 0 && currentIndex > 0 {
                    dragOffset = t * 0.4
                } else {
                    dragOffset = t * 0.15
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.width
                let shouldAdvance = (value.translation.width < -swipeThreshold || velocity < -500)
                    && currentIndex < orderedDays.count - 1
                let shouldGoBack = (value.translation.width > swipeThreshold || velocity > 500)
                    && currentIndex > 0

                if shouldAdvance || shouldGoBack {
                    withAnimation(.spring(duration: 0.45, bounce: 0.12)) {
                        if shouldAdvance {
                            currentIndex += 1
                        } else {
                            currentIndex -= 1
                        }
                        dragOffset = 0
                    }
                } else {
                    withAnimation(.spring(duration: 0.3, bounce: 0)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Data helpers

    private func saveImage(_ data: Data, for dateString: String, existingEntry: HabitEntry?) {
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
                try? FileManager.default.removeItem(at: fileURL)
                throw error
            }
        } catch {
            print("Failed to save image for \(dateString): \(error.localizedDescription)")
        }
    }

    private func resolveEntry(for dateString: String) -> HabitEntry? {
        do {
            let habitId = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitId
            }
            var descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            descriptor.fetchLimit = 2
            let results = try modelContext.fetch(descriptor)
            if results.count > 1 {
                for dup in results.dropFirst() {
                    modelContext.delete(dup)
                }
                try? modelContext.save()
            }
            return results.first
        } catch {
            return habit.entries.first(where: { $0.dateString == dateString })
        }
    }

    private func refreshDaysIfNeeded() {
        let newDays = DateUtils.generateDays(count: 7)
        guard newDays != days else { return }
        let currentDateStr = currentIndex < orderedDays.count ? orderedDays[currentIndex] : nil
        days = newDays
        if let dateStr = currentDateStr,
           let newIndex = days.sorted(by: >).firstIndex(of: dateStr) {
            currentIndex = newIndex
        } else {
            currentIndex = 0
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
