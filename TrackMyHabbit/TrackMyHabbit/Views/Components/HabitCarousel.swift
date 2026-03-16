import SwiftUI
import SwiftData
import UIKit

struct HabitCarousel: View {
    @Environment(\.modelContext) private var modelContext

    let habit: Habit
    let days: [String] = DateUtils.generateDays(count: 7)

    private let cardWidth: CGFloat = 288
    private let cardHeight: CGFloat = 397
    private let cardSpacing: CGFloat = 20

    @State private var scrollTarget: String?

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
                                withAnimation {
                                    scrollTarget = dateStr
                                }
                            },
                            onImagePicked: { data in
                                saveImage(data, for: dateStr, existingEntry: entry)
                            }
                        )
                        .scaleEffect(isActive ? 1.0 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
                        .frame(width: cardWidth, height: cardHeight)
                        .zIndex(isActive ? 1 : 0)
                    }
                }
                .padding(.vertical, 80)
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollTarget, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, horizontalInset, for: .scrollContent)
            .onAppear {
                if scrollTarget == nil {
                    scrollTarget = days.reversed().first
                }
            }
        }
        .frame(height: cardHeight + 160)
    }

    private func saveImage(_ data: Data, for dateString: String, existingEntry: HabitEntry?) {
        do {
            let fileURL = try storeImage(data, for: dateString)

            if let existingEntry {
                existingEntry.imageUri = fileURL.absoluteString
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
            print("Failed to save image for \(dateString): \(error.localizedDescription)")
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
