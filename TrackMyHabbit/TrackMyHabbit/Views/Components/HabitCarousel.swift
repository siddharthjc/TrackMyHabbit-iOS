import SwiftUI
import SwiftData

struct HabitCarousel: View {
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
                                print("Tapped on \(dateStr)")
                                withAnimation {
                                    scrollTarget = dateStr
                                }
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
}
