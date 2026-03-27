//
//  SplashScreenView.swift
//  TrackMyHabbit
//
//  Created by Siddharth Chhatpar on 18/03/26.
//

import SwiftUI

// MARK: - Splash Logo Shape

/// The four-petal clover/flower logo shape extracted from the Figma SVG.
/// Uses the exact SVG path data to render the logo natively in SwiftUI.
struct SplashLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 120
        let scaleY = rect.height / 120

        var path = Path()

        // Build the outer petals
        // M75 0
        path.move(to: CGPoint(x: 75 * scaleX, y: 0))
        // C83.15 0 89.79 6.51 89.99 14.61
        path.addCurve(
            to: CGPoint(x: 89.9948 * scaleX, y: 14.6128 * scaleY),
            control1: CGPoint(x: 83.1548 * scaleX, y: 0),
            control2: CGPoint(x: 89.7895 * scaleX, y: 6.50766 * scaleY)
        )
        // L90.005 15.387
        path.addLine(to: CGPoint(x: 90.0051 * scaleX, y: 15.3872 * scaleY))
        // C90.207 23.364 96.636 29.793 104.613 29.995
        path.addCurve(
            to: CGPoint(x: 104.613 * scaleX, y: 29.9948 * scaleY),
            control1: CGPoint(x: 90.2072 * scaleX, y: 23.3639 * scaleY),
            control2: CGPoint(x: 96.6361 * scaleX, y: 29.7928 * scaleY)
        )
        // L105.387 30.005
        path.addLine(to: CGPoint(x: 105.387 * scaleX, y: 30.0052 * scaleY))
        // C113.492 30.211 120 36.845 120 45
        path.addCurve(
            to: CGPoint(x: 120 * scaleX, y: 45 * scaleY),
            control1: CGPoint(x: 113.492 * scaleX, y: 30.2105 * scaleY),
            control2: CGPoint(x: 120 * scaleX, y: 36.8452 * scaleY)
        )
        // C120 53.284 113.284 60 105 60
        path.addCurve(
            to: CGPoint(x: 105 * scaleX, y: 60 * scaleY),
            control1: CGPoint(x: 120 * scaleX, y: 53.2842 * scaleY),
            control2: CGPoint(x: 113.284 * scaleX, y: 60 * scaleY)
        )
        // C113.284 60 120 66.716 120 75
        path.addCurve(
            to: CGPoint(x: 120 * scaleX, y: 75 * scaleY),
            control1: CGPoint(x: 113.284 * scaleX, y: 60 * scaleY),
            control2: CGPoint(x: 120 * scaleX, y: 66.7158 * scaleY)
        )
        // C120 83.155 113.492 89.79 105.387 89.995
        path.addCurve(
            to: CGPoint(x: 105.387 * scaleX, y: 89.9948 * scaleY),
            control1: CGPoint(x: 120 * scaleX, y: 83.1548 * scaleY),
            control2: CGPoint(x: 113.492 * scaleX, y: 89.7895 * scaleY)
        )
        // L104.613 90.005
        path.addLine(to: CGPoint(x: 104.613 * scaleX, y: 90.0051 * scaleY))
        // C96.636 90.207 90.207 96.636 90.005 104.613
        path.addCurve(
            to: CGPoint(x: 90.0051 * scaleX, y: 104.613 * scaleY),
            control1: CGPoint(x: 96.6361 * scaleX, y: 90.2072 * scaleY),
            control2: CGPoint(x: 90.2072 * scaleX, y: 96.6361 * scaleY)
        )
        // L89.995 105.387
        path.addLine(to: CGPoint(x: 89.9948 * scaleX, y: 105.387 * scaleY))
        // C89.79 113.492 83.155 120 75 120
        path.addCurve(
            to: CGPoint(x: 75 * scaleX, y: 120 * scaleY),
            control1: CGPoint(x: 89.7895 * scaleX, y: 113.492 * scaleY),
            control2: CGPoint(x: 83.1548 * scaleX, y: 120 * scaleY)
        )
        // C66.716 120 60 113.284 60 105
        path.addCurve(
            to: CGPoint(x: 60 * scaleX, y: 105 * scaleY),
            control1: CGPoint(x: 66.7158 * scaleX, y: 120 * scaleY),
            control2: CGPoint(x: 60 * scaleX, y: 113.284 * scaleY)
        )
        // C60 113.284 53.284 120 45 120
        path.addCurve(
            to: CGPoint(x: 45 * scaleX, y: 120 * scaleY),
            control1: CGPoint(x: 60 * scaleX, y: 113.284 * scaleY),
            control2: CGPoint(x: 53.2842 * scaleX, y: 120 * scaleY)
        )
        // C36.845 120 30.211 113.492 30.005 105.387
        path.addCurve(
            to: CGPoint(x: 30.0047 * scaleX, y: 105.387 * scaleY),
            control1: CGPoint(x: 36.8452 * scaleX, y: 120 * scaleY),
            control2: CGPoint(x: 30.2105 * scaleX, y: 113.492 * scaleY)
        )
        // L29.995 104.613
        path.addLine(to: CGPoint(x: 29.9953 * scaleX, y: 104.613 * scaleY))
        // C29.793 96.636 23.364 90.207 15.387 90.005
        path.addCurve(
            to: CGPoint(x: 15.3872 * scaleX, y: 90.0051 * scaleY),
            control1: CGPoint(x: 29.7928 * scaleX, y: 96.6361 * scaleY),
            control2: CGPoint(x: 23.3639 * scaleX, y: 90.2072 * scaleY)
        )
        // L14.613 89.995
        path.addLine(to: CGPoint(x: 14.6128 * scaleX, y: 89.9948 * scaleY))
        // C6.508 89.79 0 83.155 0 75
        path.addCurve(
            to: CGPoint(x: 0, y: 75 * scaleY),
            control1: CGPoint(x: 6.50766 * scaleX, y: 89.7895 * scaleY),
            control2: CGPoint(x: 0, y: 83.1548 * scaleY)
        )
        // C0 66.716 6.716 60 15 60
        path.addCurve(
            to: CGPoint(x: 15 * scaleX, y: 60 * scaleY),
            control1: CGPoint(x: 0, y: 66.7158 * scaleY),
            control2: CGPoint(x: 6.71578 * scaleX, y: 60 * scaleY)
        )
        // C6.716 60 0 53.284 0 45
        path.addCurve(
            to: CGPoint(x: 0, y: 45 * scaleY),
            control1: CGPoint(x: 6.71578 * scaleX, y: 60 * scaleY),
            control2: CGPoint(x: 0, y: 53.2842 * scaleY)
        )
        // C0 36.845 6.508 30.211 14.613 30.005
        path.addCurve(
            to: CGPoint(x: 14.6128 * scaleX, y: 30.0047 * scaleY),
            control1: CGPoint(x: 0, y: 36.8452 * scaleY),
            control2: CGPoint(x: 6.50766 * scaleX, y: 30.2105 * scaleY)
        )
        // L15.387 29.995
        path.addLine(to: CGPoint(x: 15.3872 * scaleX, y: 29.9953 * scaleY))
        // C23.364 29.793 29.793 23.364 29.995 15.387
        path.addCurve(
            to: CGPoint(x: 29.9948 * scaleX, y: 15.3872 * scaleY),
            control1: CGPoint(x: 23.3639 * scaleX, y: 29.7928 * scaleY),
            control2: CGPoint(x: 29.7928 * scaleX, y: 23.3639 * scaleY)
        )
        // L30.005 14.613
        path.addLine(to: CGPoint(x: 30.0052 * scaleX, y: 14.6128 * scaleY))
        // C30.211 6.508 36.845 0 45 0
        path.addCurve(
            to: CGPoint(x: 45 * scaleX, y: 0),
            control1: CGPoint(x: 30.2105 * scaleX, y: 6.50766 * scaleY),
            control2: CGPoint(x: 36.8452 * scaleX, y: 0)
        )
        // C53.284 0 60 6.716 60 15
        path.addCurve(
            to: CGPoint(x: 60 * scaleX, y: 15 * scaleY),
            control1: CGPoint(x: 53.2842 * scaleX, y: 0),
            control2: CGPoint(x: 60 * scaleX, y: 6.71578 * scaleY)
        )
        // C60 6.716 66.716 0 75 0
        path.addCurve(
            to: CGPoint(x: 75 * scaleX, y: 0),
            control1: CGPoint(x: 60 * scaleX, y: 6.71578 * scaleY),
            control2: CGPoint(x: 66.7158 * scaleX, y: 0)
        )
        path.closeSubpath()

        // Inner diamond/star cutout
        // M60 30
        path.move(to: CGPoint(x: 60 * scaleX, y: 30 * scaleY))
        // C60 46.568 46.568 60 30 60
        path.addCurve(
            to: CGPoint(x: 30 * scaleX, y: 60 * scaleY),
            control1: CGPoint(x: 60 * scaleX, y: 46.5684 * scaleY),
            control2: CGPoint(x: 46.5684 * scaleX, y: 60 * scaleY)
        )
        // C46.568 60 60 73.432 60 90
        path.addCurve(
            to: CGPoint(x: 60 * scaleX, y: 90 * scaleY),
            control1: CGPoint(x: 46.5684 * scaleX, y: 60 * scaleY),
            control2: CGPoint(x: 60 * scaleX, y: 73.4316 * scaleY)
        )
        // C60 73.432 73.432 60 90 60
        path.addCurve(
            to: CGPoint(x: 90 * scaleX, y: 60 * scaleY),
            control1: CGPoint(x: 60 * scaleX, y: 73.4316 * scaleY),
            control2: CGPoint(x: 73.4316 * scaleX, y: 60 * scaleY)
        )
        // C73.432 60 60 46.568 60 30
        path.addCurve(
            to: CGPoint(x: 60 * scaleX, y: 30 * scaleY),
            control1: CGPoint(x: 73.4316 * scaleX, y: 60 * scaleY),
            control2: CGPoint(x: 60 * scaleX, y: 46.5684 * scaleY)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Splash Logo View

/// Renders the logo with the exact gradient and inner shadow from the Figma design.
struct SplashLogoView: View {
    var size: CGFloat = AppTheme.Layout.splashLogoSize

    var body: some View {
        SplashLogoShape()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: AppTheme.Colors.emptyStateCTAStart, location: 0.0),
                        .init(color: AppTheme.Colors.emptyStateCTAMid, location: 0.42),
                        .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 1.556)
                )
            )
            .overlay(
                SplashLogoShape()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Overlay.black020, .clear],
                            startPoint: .bottom,
                            endPoint: UnitPoint(x: 0.5, y: 0.5)
                        )
                    )
                    .mask(
                        SplashLogoShape()
                            .stroke(lineWidth: AppTheme.Layout.logoInnerStrokeWidth)
                            .blur(radius: AppTheme.Layout.logoInnerBlur)
                            .offset(y: AppTheme.Layout.logoInnerOffsetY)
                    )
            )
            .overlay(
                SplashLogoShape()
                    .stroke(
                        AppTheme.Colors.ctaHairline,
                        lineWidth: AppTheme.Layout.logoStrokeWidth
                    )
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Splash Screen View

struct SplashScreenView: View {
    let onFinished: () -> Void

    // MARK: Animation state
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoRotation: Double = -90
    @State private var showTagline = false
    @State private var dismissing = false

    var body: some View {
        ZStack {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // Logo with entrance animation
                SplashLogoView(size: AppTheme.Layout.splashLogoSize)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .rotationEffect(.degrees(logoRotation))

                // Tagline — fades/slides in after logo
                if showTagline {
                    Text("Better habits start here.")
                        .customFont(.semibold, size: AppTheme.Typography.Size.xl, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.nav)
                        .foregroundColor(AppTheme.Colors.textInverse)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
        }
        .opacity(dismissing ? 0 : 1)
        .scaleEffect(dismissing ? 1.05 : 1)
        .onAppear {
            runAnimationSequence()
        }
    }

    // MARK: - Animation Sequence

    private func runAnimationSequence() {
        // Step 1: Logo entrance — scale up + fade in + rotate into place
        withAnimation(AppTheme.Motion.springSplashLogo) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoRotation = 0
        }

        // Step 2: Show tagline after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + AppTheme.Motion.durationSplashDelay) {
            withAnimation(AppTheme.Motion.easeTagline) {
                showTagline = true
            }
        }

        // Step 3: Dismiss splash and transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + AppTheme.Motion.durationSplashBeforeDismiss) {
            withAnimation(AppTheme.Motion.easeSplashDismiss) {
                dismissing = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + AppTheme.Motion.durationSplashDismissDelay) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
