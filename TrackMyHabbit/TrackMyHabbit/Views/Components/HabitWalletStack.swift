import SwiftUI
import SwiftData

private struct WalletScrollInfo: Equatable {
    var scrollOffset: CGFloat = 0
    var containerSize: CGSize = .zero
}

/// Apple Wallet-style stack of upcoming day cards for the active habit
/// (Figma 604:1934). The next six days are stacked from the top with today's
/// card at the bottom of the stack. Tapping a peeking card pins it to the
/// top while the rest slide off-screen — same interaction model as Wallet.
struct HabitWalletStack: View {
    let habit: Habit
    @Binding var selectedDate: String?
    let onPickPhoto: (String) -> Void

    @State private var info = WalletScrollInfo()
    /// Live drag translation on the pinned card (drag-to-dismiss).
    @State private var dragOffset: CGFloat = 0

    /// Days rendered top → bottom. Future days first, today last so it's
    /// drawn on top of the peeking stack.
    private var orderedDays: [String] {
        let calendar = Calendar(identifier: .gregorian)
        let upcoming = (1...AppTheme.Layout.walletUpcomingDayCount).reversed().compactMap { offset -> String? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: Date()) else { return nil }
            return DateUtils.toDateString(date: date)
        }
        return upcoming + [DateUtils.getTodayString()]
    }

    private var selectedIndex: Int {
        orderedDays.firstIndex(where: { $0 == selectedDate }) ?? 0
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: AppTheme.Layout.walletDayCardOverlap) {
                ForEach(Array(orderedDays.enumerated()), id: \.element) { index, dateStr in
                    cardView(for: dateStr, at: index)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm3)
            .padding(.bottom, AppTheme.Layout.walletBottomInset)
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(selectedDate != nil)
        .scrollClipDisabled()
        .defaultScrollAnchor(.top)
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y + proxy.contentInsets.top
        } action: { _, newValue in
            info.scrollOffset = newValue
        }
        .onScrollGeometryChange(for: CGSize.self) { proxy in
            proxy.containerSize
        } action: { _, newValue in
            info.containerSize = newValue
        }
    }

    @ViewBuilder
    private func cardView(for dateStr: String, at index: Int) -> some View {
        let isCurrent = selectedDate == dateStr
        let isCardSelected = selectedDate != nil
        let selectedCardIndex = selectedIndex
        let currentIndex = index

        WalletDayCard(
            habit: habit,
            dateStr: dateStr,
            isPinned: isCurrent,
            onPickPhoto: { onPickPhoto(dateStr) }
        )
        .onTapGesture {
            // Asymmetric springs: deliberate enter, snappier exit.
            let spring = isCurrent ? AppTheme.Motion.springWalletUnpin : AppTheme.Motion.springWalletPin
            withAnimation(spring) {
                selectedDate = isCurrent ? nil : dateStr
            }
        }
        // Opacity is scoped to its own animation so unselected cards fade out
        // faster than the spring carries them off-screen — the spec requires
        // opacity to hit 0 while they're still mid-flight. On dismiss the
        // slower easeIn lets them re-appear right as they settle into the stack.
        // Blur shares the same scope so it reads as a motion blur while the
        // cards are visible during the transition; once opacity hits 0 the
        // blur becomes invisible regardless of radius.
        .opacity((isCardSelected && !isCurrent) ? 0 : 1)
        .blur(radius: (isCardSelected && !isCurrent) ? AppTheme.Layout.walletCardTransitionBlur : 0)
        .animation(
            isCardSelected ? AppTheme.Motion.easeWalletCardFadeOut : AppTheme.Motion.easeWalletCardFadeIn,
            value: isCardSelected
        )
        // Card animation using Visual Effect API. Selected card pins to the
        // scrollview top; cards below it push past the bottom of the screen
        // and cards above push past the top — so only the selected card is
        // visible (no faint stacked-card silhouettes peeking through).
        .visualEffect { [info, isCardSelected, isCurrent, selectedCardIndex, currentIndex] content, proxy in
            let rect = proxy.frame(in: .scrollView(axis: .vertical))
            let bounds = info.containerSize

            let pushOffset: CGFloat
            if isCurrent {
                pushOffset = -rect.minY
            } else if selectedCardIndex < currentIndex {
                pushOffset = bounds.height - rect.minY
            } else {
                pushOffset = -rect.minY - bounds.height
            }

            return content
                .offset(y: isCardSelected ? pushOffset : 0)
        }
        .offset(y: isCurrent ? dragOffset : 0)
        .simultaneousGesture(dismissDragGesture(isCurrent: isCurrent))
        // Off-screen unselected cards retain their layout frame; gate hit
        // testing so they cannot intercept taps meant for the pinned card.
        .allowsHitTesting(isCurrent || !isCardSelected)
        .zIndex(isCurrent ? AppTheme.Layer.carouselActive : Double(index))
    }

    /// Drag-to-dismiss on the pinned card. Attached to every card via
    /// `simultaneousGesture` so it composes with the ScrollView's own scroll
    /// when nothing is selected; the `isCurrent` guard makes it a no-op
    /// everywhere except the pinned card.
    private func dismissDragGesture(isCurrent: Bool) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard isCurrent else { return }
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                guard isCurrent else { return }
                let translation = value.translation.height
                let predicted = value.predictedEndTranslation.height
                let shouldDismiss =
                    translation > AppTheme.Layout.walletDragDismissThreshold ||
                    predicted > AppTheme.Layout.walletDragFlickThreshold
                if shouldDismiss {
                    withAnimation(AppTheme.Motion.springWalletUnpin) {
                        selectedDate = nil
                        dragOffset = 0
                    }
                } else {
                    // Snap back to pinned — short crisp spring, no full unpin cost.
                    withAnimation(AppTheme.Motion.springWalletDragCancel) {
                        dragOffset = 0
                    }
                }
            }
    }
}

// MARK: - Day card (Figma 604:2497)

private struct WalletDayCard: View {
    let habit: Habit
    let dateStr: String
    var isPinned: Bool = false
    let onPickPhoto: () -> Void

    private var dayNumber: Int {
        DateUtils.dayNumber(createdAt: habit.createdAt, dateStr: dateStr)
    }

    private var dateLine: String {
        DateUtils.formatDateWithOrdinal(dateStr).uppercased()
    }

    private var status: DayStatus {
        let today = DateUtils.getTodayString()
        if dateStr == today { return .today }
        let calendar = Calendar(identifier: .gregorian)
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           dateStr == DateUtils.toDateString(date: tomorrow) {
            return .tomorrow
        }
        return .upcoming
    }

    private var entry: HabitEntry? {
        habit.entries.first(where: { $0.dateString == dateStr })
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            header
            photoFrame
        }
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .fill(AppTheme.Colors.bgPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .stroke(AppTheme.Colors.walletCardBorder, lineWidth: AppTheme.Spacing.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous))
        // Shadow swap is wrapped by the pin/unpin spring, so the lift animates
        // alongside the position change.
        .appShadow(isPinned ? AppTheme.Elevation.walletDayCardPinned : AppTheme.Elevation.walletDayCard)
    }

    /// Home wallet day-card header (Figma 669:1806 — `Task details` 669:1807;
    /// horizontal inset `walletCardHeaderHorizontal`).
    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm3) {
            HStack(alignment: .center, spacing: 0) {
                Text("Day \(dayNumber)")
                    .customFont(.serifsemibold,
                                size: AppTheme.Typography.Size.lg,
                                tracking: AppTheme.Typography.Tracking.nav)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer(minLength: 0)

                statusPill
            }

            Text(dateLine)
                .customFont(.semibold,
                            size: AppTheme.Typography.Size.xs,
                            tracking: AppTheme.Typography.Tracking.walletCardDate)
                .foregroundColor(AppTheme.Colors.textDisabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.walletCardHeaderHorizontal)
    }

    private var statusPill: some View {
        Text(status.label)
            .customFont(.semibold,
                        size: AppTheme.Typography.Size.xs,
                        tracking: AppTheme.Typography.Tracking.walletStatusPill)
            .foregroundColor(AppTheme.Colors.textDisabled)
            .padding(.horizontal, AppTheme.Layout.walletStatusPillHPadding)
            .padding(.vertical, AppTheme.Layout.walletStatusPillVPadding)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppTheme.Colors.textDisabled, lineWidth: AppTheme.Spacing.hairline)
            )
    }

    private var hasPhoto: Bool { entry?.imageUri != nil }

    private var photoFrame: some View {
        photoFrameContent
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Layout.calendarPhotoFrameHeight)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .fill(AppTheme.Colors.bgPrimary)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .overlay {
                if !hasPhoto {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                        .strokeBorder(
                            AppTheme.Colors.calendarDayChipRestFill,
                            style: StrokeStyle(lineWidth: AppTheme.Spacing.hairline, dash: [6, 4])
                        )
                }
            }
            .appShadow(AppTheme.Elevation.walletPhotoFrame)
            .padding(.horizontal, AppTheme.Spacing.sm3)
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .onTapGesture { onPickPhoto() }
    }

    @ViewBuilder
    private var photoFrameContent: some View {
        if let uri = entry?.imageUri, let url = URL(string: uri) {
            // GeometryReader + explicit frame + .clipped() — same pattern as
            // `DayCard.photoCard`. Without this, AsyncImage's `.aspectRatio(.fill)`
            // reports an intrinsic size larger than the parent and the photo
            // bleeds out of the card.
            GeometryReader { proxy in
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    AppTheme.Overlay.grayPhotoPlaceholder
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        } else {
            VStack(spacing: AppTheme.Spacing.calendarAddOrbTitle) {
                AddPhotoOrb()
                    .frame(
                        width: AppTheme.Layout.calendarAddOrbSize,
                        height: AppTheme.Layout.calendarAddOrbSize
                    )
                Text("Add photo")
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.md,
                        lineHeight: AppTheme.Typography.Line.body192,
                        tracking: AppTheme.Typography.Tracking.tight
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }

    private enum DayStatus {
        case today, tomorrow, upcoming

        var label: String {
            switch self {
            case .today: return "TODAY"
            case .tomorrow: return "TOMORROW"
            case .upcoming: return "UPCOMING"
            }
        }
    }
}
