//
//  LiquidGlassIntroView.swift
//  TrackMyHabbit
//
//  Liquid-glass swipe intro adapted from Wabi-Intro (https://github.com/sforsethi/Wabi-Intro).
//

import SwiftUI
import UIKit

/// Launch routing / persistence for the first-run liquid intro (`TrackMyHabbitApp`).
enum LiquidGlassIntroLaunch {
    /// Passed via `XCUIApplication.launchArguments` so UI tests skip the intro.
    static let skipCommandLineArgument = "-skipLiquidIntro"

    private static let completedKey = "liquidGlassIntroCompleted"

    static var shouldSkipForTesting: Bool {
        ProcessInfo.processInfo.arguments.contains(skipCommandLineArgument)
    }

    static var hasUserCompletedIntro: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }
}

struct LiquidGlassIntroView<Destination: View>: View {
    let revealBackground: Color
    let destination: () -> Destination
    let onComplete: () -> Void

    init(
        revealBackground: Color,
        @ViewBuilder destination: @escaping () -> Destination,
        onComplete: @escaping () -> Void
    ) {
        self.revealBackground = revealBackground
        self.destination = destination
        self.onComplete = onComplete
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dragProgress: CGFloat = 0
    @State private var dragStartProgress: CGFloat?
    @State private var horizontalOffset: CGFloat = 0
    @State private var horizontalDragStart: CGFloat?
    @State private var dragHaptics = DragHapticDriver()

    @State private var transitionPhase: TransitionPhase = .idle
    @State private var burstProgress: Double = 0
    @State private var revealProgress: CGFloat = 0
    @State private var destinationOpacity: Double = 0
    @State private var liquidGlassOpacity: Double = 1

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let bubble = bubbleState(in: size)
            let diagonal = hypot(size.width, size.height)
            let revealRadius = max(revealProgress * diagonal, 0)

            ZStack {
                revealBackground
                    .ignoresSafeArea()
                    .mask(alignment: .topLeading) {
                        revealMask(radius: revealRadius, center: bubble.center, size: size)
                    }

                destination()
                    .opacity(destinationOpacity)
                    .mask(alignment: .topLeading) {
                        revealMask(radius: revealRadius, center: bubble.center, size: size)
                    }
                    .allowsHitTesting(transitionPhase == .done)

                if transitionPhase != .done && transitionPhase != .fadingIn {
                    liquidGlassLayer(size: size, bubble: bubble)
                        .opacity(liquidGlassOpacity)
                        .allowsHitTesting(transitionPhase == .idle)
                }

                if transitionPhase == .exploding || transitionPhase == .revealing {
                    AppleIntelligenceBurstView(
                        center: bubble.center,
                        progress: burstProgress,
                        maxRadius: diagonal
                    )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { handleAppear() }
    }

    private func revealMask(radius: CGFloat, center: CGPoint, size: CGSize) -> some View {
        Circle()
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    private func liquidGlassLayer(size: CGSize, bubble: BubbleState) -> some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate

            liquidGlassBackground(size: size)
                .layerEffect(
                    ShaderLibrary.tmhLiquidGlass(
                        .float2(Float(size.width), Float(size.height)),
                        .float2(Float(bubble.center.x), Float(bubble.center.y)),
                        .float(Float(bubble.radius)),
                        .float(Float(AppTheme.Motion.liquidIntroGlassRefraction)),
                        .float(Float(bubble.shadowBlur)),
                        .float(Float(elapsed))
                    ),
                    maxSampleOffset: CGSize(width: bubble.maxSampleOffset, height: bubble.maxSampleOffset)
                )
                .contentShape(Rectangle())
                .gesture(bubbleDragGesture(in: size))
                .simultaneousGesture(
                    TapGesture().onEnded {
                        guard transitionPhase == .idle else { return }
                        if dragProgress < 0.5 {
                            triggerTransitionFromGesture()
                        } else {
                            withAnimation(AppTheme.Motion.springLiquidIntroTapToggle) {
                                dragProgress = 0
                            }
                        }
                    }
                )
                .frame(width: size.width, height: size.height)
                .clipped()
                .overlay(alignment: .bottom) {
                    Text("SWIPE UP TO BEGIN")
                        .customFont(
                            .semibold,
                            size: AppTheme.Typography.Size.sm,
                            lineHeight: AppTheme.Typography.Line.body192,
                            tracking: AppTheme.Typography.Tracking.uppercaseLabel
                        )
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .offset(y: -abs(sin(elapsed * AppTheme.Motion.liquidIntroSwipeHintOscillationSpeed))
                            * AppTheme.Layout.liquidIntroSwipeHintOscillation)
                        .opacity(max(1.0 - dragProgress * 5, 0))
                        .padding(.bottom, AppTheme.Spacing.liquidIntroSwipeHintBottom)
                }
        }
    }

    private func liquidGlassBackground(size: CGSize) -> some View {
        ZStack {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            Text("Proof you\nshowed up.")
                .customFont(
                    .serifsemibold,
                    size: AppTheme.Typography.Size.liquidIntroTitle,
                    lineHeight: AppTheme.Typography.Line.title29,
                    tracking: AppTheme.Typography.Tracking.titleXL
                )
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.72)
                .blendMode(colorScheme == .light ? .multiply : .normal)
                .offset(y: AppTheme.Layout.liquidIntroTitleStackOffsetY)
        }
    }

    // MARK: - Transition orchestration

    private func handleAppear() {
        guard transitionPhase == .idle else { return }
        if LiquidGlassIntroLaunch.shouldSkipForTesting {
            DispatchQueue.main.async {
                transitionPhase = .done
                LiquidGlassIntroLaunch.markCompleted()
                onComplete()
            }
        }
    }

    private func triggerTransitionFromGesture() {
        guard transitionPhase == .idle else { return }
        transitionPhase = .snapping
        withAnimation(AppTheme.Motion.springIntroSnap) {
            dragProgress = 1
            horizontalOffset = 0
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + AppTheme.Motion.durationIntroSettlePause
        ) {
            guard transitionPhase == .snapping else { return }
            if reduceMotion {
                runReducedMotionTransition()
            } else {
                runFullTransition()
            }
        }
    }

    private func runFullTransition() {
        transitionPhase = .exploding
        withAnimation(.linear(duration: AppTheme.Motion.durationIntroBurst)) {
            burstProgress = 1
        }

        let revealStartDelay = AppTheme.Motion.durationIntroBurst * 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + revealStartDelay) {
            guard transitionPhase == .exploding else { return }
            transitionPhase = .revealing
            withAnimation(.easeOut(duration: AppTheme.Motion.durationIntroReveal)) {
                revealProgress = 1
                liquidGlassOpacity = 0
            }
        }

        let fadeInStartDelay = revealStartDelay + AppTheme.Motion.durationIntroReveal
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeInStartDelay) {
            guard transitionPhase == .revealing else { return }
            transitionPhase = .fadingIn
            withAnimation(.easeIn(duration: AppTheme.Motion.durationIntroDestinationFade)) {
                destinationOpacity = 1
            }
        }

        let doneDelay = fadeInStartDelay + AppTheme.Motion.durationIntroDestinationFade
        DispatchQueue.main.asyncAfter(deadline: .now() + doneDelay) {
            finishTransition()
        }
    }

    private func runReducedMotionTransition() {
        transitionPhase = .fadingIn
        revealProgress = 1
        burstProgress = 0

        let total = AppTheme.Motion.durationIntroBurst
            + AppTheme.Motion.durationIntroReveal
            + AppTheme.Motion.durationIntroDestinationFade

        withAnimation(.easeInOut(duration: total)) {
            liquidGlassOpacity = 0
            destinationOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + total) {
            finishTransition()
        }
    }

    private func finishTransition() {
        guard transitionPhase != .done else { return }
        transitionPhase = .done
        LiquidGlassIntroLaunch.markCompleted()
        onComplete()
    }

    // MARK: - Gestures and bubble math

    private func bubbleDragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard transitionPhase == .idle else { return }
                if dragStartProgress == nil {
                    dragStartProgress = dragProgress
                    horizontalDragStart = horizontalOffset
                    dragHaptics.start()
                }

                let travel = max(size.height * AppTheme.Layout.liquidIntroSwipeTravelRatio, 1)
                let startProgress = dragStartProgress ?? dragProgress
                dragProgress = min(max(startProgress - value.translation.height / travel, 0), 1)

                let startHorizontal = horizontalDragStart ?? horizontalOffset
                horizontalOffset = startHorizontal + value.translation.width
            }
            .onEnded { _ in
                let releaseProgress = dragProgress
                dragStartProgress = nil
                horizontalDragStart = nil
                dragHaptics.stop()

                guard transitionPhase == .idle else { return }
                if releaseProgress >= AppTheme.Layout.liquidIntroSnapThreshold {
                    triggerTransitionFromGesture()
                } else {
                    withAnimation(AppTheme.Motion.springLiquidIntroDragSettle) {
                        dragProgress = 0
                        horizontalOffset = 0
                    }
                }
            }
    }

    private func bubbleState(in size: CGSize) -> BubbleState {
        let expandedRadius = max(
            size.width * AppTheme.Layout.liquidIntroBubbleExpandedWidthMultiplier,
            AppTheme.Layout.liquidIntroBubbleMinExpandedRadius
        )
        let collapsedRadius = AppTheme.Layout.liquidIntroBubbleCollapsedRadius
        let progress = min(max(dragProgress, 0), 1)
        let radius = expandedRadius + (collapsedRadius - expandedRadius) * progress
        let expandedCenter = CGPoint(
            x: size.width / 2,
            y: size.height + expandedRadius - AppTheme.Layout.liquidIntroBubbleExpandedBottomInset
        )
        let collapsedCenter = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - AppTheme.Layout.liquidIntroBubbleCollapsedCenterOffsetY
        )
        let center = CGPoint(
            x: expandedCenter.x + (collapsedCenter.x - expandedCenter.x) * progress + horizontalOffset,
            y: expandedCenter.y + (collapsedCenter.y - expandedCenter.y) * progress
        )

        let shadowBlurUnclamped = radius * AppTheme.Layout.liquidIntroBubbleShadowBlurFactor
        let shadowBlur = min(
            max(shadowBlurUnclamped, AppTheme.Layout.liquidIntroBubbleShadowBlurMin),
            AppTheme.Layout.liquidIntroBubbleShadowBlurMax
        )

        let maxSample = min(
            max(radius * 2, AppTheme.Layout.liquidIntroLayerEffectMinSampleFloor),
            AppTheme.Layout.liquidIntroLayerEffectMaxSampleOffset
        )

        return BubbleState(
            center: center,
            radius: radius,
            shadowBlur: shadowBlur,
            maxSampleOffset: maxSample
        )
    }
}

private enum TransitionPhase {
    case idle
    case snapping
    case exploding
    case revealing
    case fadingIn
    case done
}

private final class DragHapticDriver {
    private let generator = UIImpactFeedbackGenerator(style: .soft)
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        generator.prepare()
        play()
    }

    func stop() {
        isRunning = false
    }

    private func play() {
        guard isRunning else { return }

        generator.impactOccurred(intensity: 0.12)
        generator.prepare()

        DispatchQueue.main.asyncAfter(deadline: .now() + AppTheme.Motion.durationLiquidIntroHapticPulse) { [weak self] in
            self?.play()
        }
    }
}

private struct BubbleState {
    let center: CGPoint
    let radius: CGFloat
    let shadowBlur: CGFloat
    let maxSampleOffset: CGFloat
}

#Preview {
    LiquidGlassIntroView(
        revealBackground: AppTheme.Colors.emptyStateBackground,
        destination: { Color.clear },
        onComplete: {}
    )
}
