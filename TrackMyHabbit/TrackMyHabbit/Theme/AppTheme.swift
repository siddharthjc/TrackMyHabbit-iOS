import SwiftUI

// MARK: - AppTheme (Layer 2 semantic API; mirrors tokens.css)

enum AppTheme {

    // MARK: - Layer 1 — Primitives (DS)

    enum Neutral {
        static let _0 = Color(hex: "#ffffff")
        static let _100 = Color(hex: "#fafafc")
        static let _200 = Color(hex: "#f5f5f8")
        static let _300 = Color(hex: "#e9e9ef")
        static let _400 = Color(hex: "#d4d4dc")
        static let _500 = Color(hex: "#b3b3c3")
        static let _600 = Color(hex: "#8a8a9f")
        static let _700 = Color(hex: "#5e5e72")
        static let _800 = Color(hex: "#2e2e3d")
        static let _900 = Color(hex: "#1a1a25")
    }

    enum Brand {
        static let _0 = Color(hex: "#f3f1ff")
        static let _100 = Color(hex: "#e2dfff")
        static let _200 = Color(hex: "#c7c0fb")
        static let _300 = Color(hex: "#aba0f5")
        static let _400 = Color(hex: "#8f84ee")
        static let _500 = Color(hex: "#7569e0")
        static let _600 = Color(hex: "#6253d5")
        static let _700 = Color(hex: "#4d3dbd")
        static let _800 = Color(hex: "#392c9d")
    }

    // MARK: - Layer 2 — Semantic colors

    enum Colors {
        static let textPrimary = Color(hex: "#16191d")
        static let textSecondary = Color(hex: "#5b6271")
        static let textDisabled = Color(hex: "#8c95a6")

        static let bgPrimary = Neutral._0
        static let bgSecondary = Color(hex: "#f6f7f9")
        static let bgTertiary = Color(hex: "#edeff3")

        static let systemBlue = Color(hex: "#007aff")
        static let primary = Brand._600
        static let primaryLight = Brand._0
        static let cardBorder = Brand._200

        static let emptyStateBackground = Color(hex: "#f9fafa")
        static let emptyStateCardTint = Color(hex: "#f0f3ff")
        static let emptyStateCTAStart = Color(hex: "#6f8eff")
        static let emptyStateCTAMid = Color(hex: "#4d6fea")
        static let emptyStateCTAEnd = Color(hex: "#5778f1")

        static let destructive = Color(hex: "#e53935")
        static let surfaceSelected = Color(hex: "#e1e5ea")
        static let gradientDayCardStart = Color(hex: "#e2e8ff")

        /// Inset rim on empty-state CTA (matches tokens `--ds-cta-navy-rim`).
        static let ctaInsetNavy = Color(red: 18 / 255, green: 28 / 255, blue: 92 / 255)
        static let ctaHairline = Neutral._600.opacity(0.23)
    }

    // MARK: - Spacing (aligns with --space-* in tokens.css)

    enum Spacing {
        static let xs: CGFloat = 4 // --space-1
        static let sm: CGFloat = 8 // --space-2
        static let sm3: CGFloat = 12 // --space-3
        static let md: CGFloat = 16 // --space-4
        static let lg: CGFloat = 20 // --space-5
        static let xl: CGFloat = 24 // --space-6
        static let xl2: CGFloat = 32 // --space-7
        static let xxl: CGFloat = 40 // --space-8
        static let xxxl: CGFloat = 80 // --space-9

        static let hairline: CGFloat = 1 // --space-10
        static let insetFine: CGFloat = 1.5 // --space-11
        static let relaxed: CGFloat = 18 // --space-12
        static let block: CGFloat = 36 // --space-13
        static let touch: CGFloat = 48 // --space-14
        static let dropdownOffsetTop: CGFloat = 74 // --space-15
        static let sheetScrollReserve: CGFloat = 380 // --space-16

        static let sectionTop: CGFloat = 40
        static let sectionBottom: CGFloat = 32
        static let tabBarBottomInset: CGFloat = 20
        static let tabBarTopInset: CGFloat = 8
        static let emptyStateMinSpacer: CGFloat = 18
        static let emptyStateBottomSpacer: CGFloat = 8
    }

    // MARK: - Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xl2: CGFloat = 30
        static let pill: CGFloat = 56
        static let glass: CGFloat = 28
        static let full: CGFloat = 999
    }

    // MARK: - Typography scale

    enum Typography {
        enum Size {
            static let xs: CGFloat = 12
            static let sm: CGFloat = 14
            static let md: CGFloat = 16
            static let lg: CGFloat = 20
            static let xl: CGFloat = 24
            static let display: CGFloat = 40
        }

        enum Tracking {
            static let titleXL: CGFloat = -0.48
            static let body: CGFloat = -0.08
            static let tight: CGFloat = -0.32
            static let nav: CGFloat = -0.4
            static let suggestion: CGFloat = -0.07
            static let caption: CGFloat = -0.14
        }

        enum Line {
            static let title29: CGFloat = 29
            static let title288: CGFloat = 28.8
            static let body192: CGFloat = 19.2
            static let body224: CGFloat = 22.4
            static let body196: CGFloat = 19.6
            static let body20: CGFloat = 20
            static let body24: CGFloat = 24
        }
    }

    // MARK: - Motion

    enum Motion {
        static let durationInstant: Double = 0.1
        static let durationFast: Double = 0.18
        static let durationNormal: Double = 0.25
        static let durationMedium: Double = 0.3
        static let durationSlow: Double = 0.4
        static let durationEmphasis: Double = 0.45
        static let durationReveal: Double = 0.5
        static let durationSplashDelay: Double = 0.6
        /// Delay after dismiss animation before `onFinished` (splash handoff).
        static let durationSplashDismissDelay: Double = 0.45
        /// Time before splash begins dismiss sequence (logo + tagline).
        static let durationSplashBeforeDismiss: Double = 1.8

        /// Nanoseconds matching `durationNormal` (empty-state CTA → create sheet).
        static let createSheetDelayNanoseconds: UInt64 = 250_000_000

        static let springCTA = Animation.spring(response: 0.18, dampingFraction: 0.86)
        static let springFrequency = Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let springSplashLogo = Animation.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0)
        static let springCarouselSettle = Animation.spring(duration: 0.45, bounce: 0.12)
        static let springCarouselReset = Animation.spring(duration: 0.3, bounce: 0)
        static let springSheetOverlay = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)

        static var easeTab: Animation { .easeInOut(duration: durationNormal) }
        static var easeSheetIn: Animation { .easeIn(duration: durationFast) }
        static var easeSheetOut: Animation { .easeOut(duration: durationFast) }
        static var easeTagline: Animation { .easeOut(duration: durationReveal) }
        static var easeSplashDismiss: Animation { .easeInOut(duration: durationSlow) }
        static var easeFrequencyPress: Animation { .easeOut(duration: durationInstant) }
    }

    // MARK: - Elevation (shadow tokens)

    struct ShadowToken {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    enum Elevation {
        static let sheet = ShadowToken(color: Neutral._700.opacity(0.2), radius: 28, x: 0, y: 4)
        static let floatingCircularButton = ShadowToken(color: Neutral._700.opacity(0.4), radius: 56, x: 0, y: 4.416)
        static let suggestionChip = ShadowToken(color: Neutral._700.opacity(0.2), radius: 56, x: 0, y: 4.416)
        static let dropdownCard = ShadowToken(color: Neutral._700.opacity(0.2), radius: 56, x: 0, y: 4.416)

        static func dayCard(isActive: Bool) -> ShadowToken {
            ShadowToken(
                color: Neutral._700.opacity(isActive ? 0.2 : 0.08),
                radius: isActive ? 56 : 36,
                x: 0,
                y: 2
            )
        }

        static let ctaOuter = ShadowToken(color: Neutral._700.opacity(0.3), radius: 1.25, x: 0, y: 1)

        static let photoLabelText = ShadowToken(color: Overlay.black022, radius: 3, x: 0, y: 1)
        static let glassDark = ShadowToken(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
        static let glassLight = ShadowToken(color: Overlay.white035, radius: 8, x: 0, y: -1)
    }

    // MARK: - z-index (carousel)

    enum Layer {
        static let carouselBack: Double = 150
        static let carouselActive: Double = 100
        static let carouselStackBase: Double = 50
    }

    // MARK: - Layout constants (carousel / hero)

    enum Layout {
        static let dayCardWidth: CGFloat = 288
        static let dayCardHeight: CGFloat = 397
        static let carouselExtraHeight: CGFloat = 160
        static let carouselScaleStep: CGFloat = 0.9
        static let carouselCardStep: CGFloat = 47
        static let carouselMaxVisibleBehind: Int = 2
        static let carouselSwipeThreshold: CGFloat = 60
        static let carouselLeftPeek: CGFloat = 12
        static let carouselEdgeClamp: CGFloat = 20
        static let carouselDragMin: CGFloat = 20
        static let carouselVelocityThreshold: CGFloat = 500
        static let carouselDragResistanceOuter: CGFloat = 0.4
        static let carouselDragResistanceEdge: CGFloat = 0.15
        static let carouselProgressDivisor: CGFloat = 0.5
        static let habitChipSpacing: CGFloat = 6
        static let habitChipActiveSpacing: CGFloat = 8
        static let emptyHeroWidth: CGFloat = 402
        static let emptyHeroAspect: CGFloat = 456.0 / 402.0
        static let minTouchTarget: CGFloat = 44
        static let navIconSize: CGFloat = 48
        static let patternDotSpacing: CGFloat = 22
        static let patternDotRadius: CGFloat = 1.2
        static let patternDotOpacity: Double = 0.10
        static let splashLogoSize: CGFloat = 120
        static let glassBarHeight: CGFloat = 56
        static let photoGradientHeight: CGFloat = 80
        static let photoOverlayOpacity: Double = 0.18
        static let placeholderGray: Double = 0.3
        static let logoStrokeWidth: CGFloat = 0.2
        static let logoInnerBlur: CGFloat = 1
        static let logoInnerOffsetY: CGFloat = -1.5
        static let logoInnerStrokeWidth: CGFloat = 3
    }

    // MARK: - Liquid glass material opacities

    enum Glass {
        static let fillTop: Double = 0.42
        static let fillBottom: Double = 0.16
        static let stroke: Double = 0.78
        static let innerTop: Double = 0.48
        static let innerBottom: Double = 0.02
        static let innerShadow: Double = 0.2
    }

    enum Opacity {
        static let emptyStatePlaceholder: Double = 0.5
    }

    /// Standard black/white overlays (maps to rgba patterns in specs).
    enum Overlay {
        static let black018 = Color.black.opacity(0.18)
        static let black020 = Color.black.opacity(0.2)
        static let black022 = Color.black.opacity(0.22)
        static let black055 = Color.black.opacity(0.55)
        static let black000 = Color.black.opacity(0)
        static let black030 = Color.black.opacity(0.30)

        static let white035 = Color.white.opacity(0.35)
        static let white042 = Color.white.opacity(0.42)
        static let white016 = Color.white.opacity(0.16)
        static let white078 = Color.white.opacity(0.78)
        static let white048 = Color.white.opacity(0.48)
        static let white002 = Color.white.opacity(0.02)

        static let grayPhotoPlaceholder = Color.gray.opacity(Layout.placeholderGray)
    }
}

// MARK: - Shadow helper

extension View {
    func appShadow(_ token: AppTheme.ShadowToken) -> some View {
        shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
