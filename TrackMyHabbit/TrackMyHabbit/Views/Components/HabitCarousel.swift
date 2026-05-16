import SwiftUI
import SwiftData

struct HabitCarousel: View {
    @Environment(\.modelContext) private var modelContext

    let habit: Habit
    @State private var days: [String] = DateUtils.generateDays(count: 7)
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private var cardWidth: CGFloat { AppTheme.Layout.dayCardWidth }
    private var cardHeight: CGFloat { AppTheme.Layout.dayCardHeight }
    private var scaleStep: CGFloat { AppTheme.Layout.carouselScaleStep }
    private var cardStep: CGFloat { AppTheme.Layout.carouselCardStep }
    private var maxVisibleBehind: Int { AppTheme.Layout.carouselMaxVisibleBehind }
    private var swipeThreshold: CGFloat { AppTheme.Layout.carouselSwipeThreshold }
    @State private var screenWidth: CGFloat = 393 // updated by GeometryReader
    private var leftPeekFromEdge: CGFloat { AppTheme.Layout.carouselLeftPeek }

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
        .frame(height: cardHeight + AppTheme.Layout.carouselExtraHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            screenWidth = newWidth
        }
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
        let maxLeftShift = -(screenWidth / 2 - cardWidth / 2 - AppTheme.Layout.carouselEdgeClamp)
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
            ? min(-dragOffset / (cardWidth * AppTheme.Layout.carouselProgressDivisor), 1.0)
            : 0
        let rightProgress: CGFloat = dragOffset > 0
            ? min(dragOffset / (cardWidth * AppTheme.Layout.carouselProgressDivisor), 1.0)
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
        .zIndex(depth < 0 ? AppTheme.Layer.carouselBack : (depth == 0 ? AppTheme.Layer.carouselActive : AppTheme.Layer.carouselStackBase - Double(depth)))
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
        DragGesture(minimumDistance: AppTheme.Layout.carouselDragMin)
            .onChanged { value in
                let t = value.translation.width
                if t < 0 && currentIndex < orderedDays.count - 1 {
                    dragOffset = t
                } else if t > 0 && currentIndex > 0 {
                    dragOffset = t * AppTheme.Layout.carouselDragResistanceOuter
                } else {
                    dragOffset = t * AppTheme.Layout.carouselDragResistanceEdge
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.width
                let shouldAdvance = (value.translation.width < -swipeThreshold || velocity < -AppTheme.Layout.carouselVelocityThreshold)
                    && currentIndex < orderedDays.count - 1
                let shouldGoBack = (value.translation.width > swipeThreshold || velocity > AppTheme.Layout.carouselVelocityThreshold)
                    && currentIndex > 0

                if shouldAdvance || shouldGoBack {
                    withAnimation(AppTheme.Motion.springCarouselSettle) {
                        if shouldAdvance {
                            currentIndex += 1
                        } else {
                            currentIndex -= 1
                        }
                        dragOffset = 0
                    }
                } else {
                    withAnimation(AppTheme.Motion.springCarouselReset) {
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
            var previousImageURI: String?
            var insertedEntry: HabitEntry?

            do {
                if let resolvedEntry {
                    previousImageURI = resolvedEntry.imageUri
                    resolvedEntry.imageUri = fileURL.absoluteString
                } else {
                    let newEntry = HabitEntry(
                        dateString: dateString,
                        imageUri: fileURL.absoluteString,
                        habit: habit
                    )
                    insertedEntry = newEntry
                    modelContext.insert(newEntry)
                }

                try modelContext.save()
                HabitPhotoFileStore.removePhoto(at: previousImageURI)
            } catch {
                if let insertedEntry {
                    modelContext.delete(insertedEntry)
                }
                modelContext.rollback()
                HabitPhotoFileStore.removePhoto(at: fileURL.absoluteString)
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
        try HabitPhotoFileStore.persistJPEG(data: data, habitID: habit.id, dateString: dateString)
    }
}
