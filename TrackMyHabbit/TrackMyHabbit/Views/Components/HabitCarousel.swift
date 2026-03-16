import SwiftUI
import SwiftData

struct HabitCarousel: View {
    let habit: Habit
    let days: [String] = DateUtils.generateDays(count: 7)
    
    let cardWidth = UIScreen.main.bounds.width * 0.72
    var cardHeight: CGFloat { cardWidth * 1.38 }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(days.reversed(), id: \.self) { dateStr in
                    let entry = habit.entries.first(where: { $0.dateString == dateStr })
                    
                    GeometryReader { proxy in
                        let midX = proxy.frame(in: .global).midX
                        let screenMidX = UIScreen.main.bounds.midX
                        let distance = abs(midX - screenMidX)
                        let isActive = distance < (cardWidth / 2 + 10)
                        
                        DayCard(
                            dateStr: dateStr,
                            entry: entry,
                            isActive: isActive,
                            tapAction: {
                                // Image picking logic to be implemented here
                                print("Tapped on \(dateStr)")
                            }
                        )
                        .scaleEffect(isActive ? 1.0 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isActive)
                    }
                    .frame(width: cardWidth, height: cardHeight)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, (UIScreen.main.bounds.width - cardWidth) / 2, for: .scrollContent)
    }
}
