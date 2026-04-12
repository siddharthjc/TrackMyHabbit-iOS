import SwiftUI
import UIKit

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

    // MARK: - Layer 2 — Semantic colors (light / dark; Figma dark: 263:3338, 263:3320)

    enum Colors {
        private static func semantic(_ light: String, _ dark: String) -> Color {
            Color(UIColor { tc in
                UIColor(hex: tc.userInterfaceStyle == .dark ? dark : light)
            })
        }

        private static func semantic(_ light: UIColor, _ dark: UIColor) -> Color {
            Color(UIColor { tc in
                tc.userInterfaceStyle == .dark ? dark : light
            })
        }

        static let textPrimary = semantic("#16191d", "#fafafa")
        static let textSecondary = semantic("#5b6271", "#6e6e6e")
        static let textDisabled = semantic("#8c95a6", "#636366")

        static let bgPrimary = semantic("#ffffff", "#171717")
        static let bgSecondary = semantic("#f6f7f9", "#1c1c1e")
        static let bgTertiary = semantic("#edeff3", "#2c2c2e")

        /// Tab bar accent (Figma `--accents/blue`).
        static let tabBarAccent = semantic("#007aff", "#0091ff")

        static let systemBlue = Color(UIColor.systemBlue)
        static let primary = semantic("#6253d5", "#8f84ee")
        static let primaryLight = semantic("#f3f1ff", "#2e2654")
        static let cardBorder = semantic("#c7c0fb", "#4a3f8a")

        static let emptyStateBackground = semantic("#f9fafa", "#171717")
        static let emptyStateCardTint = semantic("#f0f3ff", "#1c1c1e")
        static let emptyStateCTAStart = Color(hex: "#6f8eff")
        static let emptyStateCTAMid = Color(hex: "#4d6fea")
        static let emptyStateCTAEnd = Color(hex: "#5778f1")

        static let destructive = semantic("#e53935", "#ff453a")
        static let surfaceSelected = semantic("#e1e5ea", "#3a3a3c")
        static let gradientDayCardStart = semantic("#e2e8ff", "#171717")
        static let gradientDayCardEnd = semantic("#ffffff", "#212121")

        static let dayCardFill = semantic("#ffffff", "#1a1a1a")
        static let borderSubtle = semantic("#e9e9ef", "#212121")
        static let chipBackground = semantic("#ffffff", "#2c2c2e")

        /// Calendar shell card border (Figma neutral-200 `#eeeeee`).
        static let calendarShellBorder = semantic("#eeeeee", "#2c2c2e")
        /// Selected day chip fill (Figma neutral-950 `#18191b`).
        static let calendarDaySelectedFill = semantic("#18191b", "#3a3a3c")
        /// Hairline on selected day chip (Figma white ring).
        static let calendarDaySelectedStroke = semantic("#ffffff", "#48484a")
        /// Habit name pill on calendar card (Figma pond-blue-50 / 900).
        static let calendarHabitChipFill = semantic("#eef3ff", "#2e2654")
        static let calendarHabitChipText = semantic("#0e2772", "#c7c0fb")
        /// Placeholder footer pills on the calendar empty-photo card (Figma 389:5199).
        static let calendarPlaceholderPillBlueFill = calendarHabitChipFill
        static let calendarPlaceholderPillBlueText = calendarHabitChipText
        static let calendarPlaceholderPillOrangeFill = semantic("#fff3ed", "#3b2a1f")
        static let calendarPlaceholderPillOrangeText = semantic("#7f2a10", "#ffb28b")
        static let calendarPlaceholderPillGreenFill = semantic("#ecfef7", "#183327")
        static let calendarPlaceholderPillGreenText = semantic("#003221", "#b7e9d0")
        /// Placeholder footer pills — pressed/selected (darker fill; Figma 410:7611).
        static let calendarPlaceholderPillBlueFillSelected = semantic("#c5d9ff", "#3d3458")
        static let calendarPlaceholderPillOrangeFillSelected = semantic("#ffe0d0", "#4a3828")
        static let calendarPlaceholderPillGreenFillSelected = semantic("#d0f5e8", "#244a3a")
        /// White inner rim on photo frame when a footer tag is selected (`innerInsetRim`).
        static let calendarPhotoSelectedInnerShadow = semantic(
            UIColor(white: 1, alpha: 0.52),
            UIColor(white: 1, alpha: 0.26)
        )
        /// Selected tag inner shadow — white (Figma Tag: inner shadow #FFFFFF @ 80%, blur 9.5, spread 2, offset 0).
        static let calendarPlaceholderPillTagInnerShadow = semantic(
            UIColor(white: 1, alpha: 0.8),
            UIColor(white: 1, alpha: 0.42)
        )

        /// Inset rim on empty-state CTA (matches tokens `--ds-cta-navy-rim`).
        static let ctaInsetNavy = Color(red: 18 / 255, green: 28 / 255, blue: 92 / 255)
        static let ctaHairline = semantic(
            UIColor(red: 138 / 255, green: 138 / 255, blue: 159 / 255, alpha: 0.23),
            UIColor(white: 1, alpha: 0.23)
        )

        /// Text on photos, gradient CTAs, and dark media (always light).
        static let textInverse = semantic("#ffffff", "#ffffff")

        /// Dotted marketing background (`EmptyStateBackgroundPattern`).
        static let patternDot = semantic(
            UIColor(red: 179 / 255, green: 179 / 255, blue: 195 / 255, alpha: 0.10),
            UIColor(white: 1, alpha: 0.12)
        )
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
        /// Title ↔ day-chip column (Figma 389:5153).
        static let calendarHeaderInner: CGFloat = 10
        /// Vertical gap from day-chip row bottom to calendar habit card top (Figma 397:6240 — 24px).
        static let calendarDayStripToCard: CGFloat = 24
        /// Horizontal gap between calendar day chips (tighter than 24pt artboard for denser strip).
        static let calendarDayChipGap: CGFloat = 16
        /// Add-photo orb ↔ title (Figma 389:5195).
        static let calendarAddOrbTitle: CGFloat = 11
        /// Top inset for the centered empty-photo CTA stack (Figma 389:5195).
        static let calendarPlaceholderTopInset: CGFloat = 124
        /// Vertical inset so day-chip drop shadows are not clipped by the parent scroll view (Figma dev).
        static let calendarChipStripShadowBleed: CGFloat = 16
        /// Inset around calendar habit cards inside horizontal `ScrollView` so shell blur 72 is not clipped (Figma drop shadow).
        static let calendarHabitCardShadowBleed: CGFloat = 80

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
        /// Calendar outer habit card (Figma 389:5191).
        static let calendarShell: CGFloat = 32
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
            /// Upper weekday row on calendar day chips (Figma 389:5150).
            static let calendarDayAbbrev: CGFloat = 10
            /// Plus icon inside calendar add-photo orb (Figma 389:5197).
            static let calendarPlusGlyph: CGFloat = 32
        }

        enum Tracking {
            static let titleXL: CGFloat = -0.48
            static let body: CGFloat = -0.08
            static let tight: CGFloat = -0.32
            static let calendarDayAbbrev: CGFloat = -0.1
            static let calendarDayNumber: CGFloat = -0.32
            static let calendarHabitChip: CGFloat = -0.06
            static let nav: CGFloat = -0.4
            static let suggestion: CGFloat = -0.07
            static let caption: CGFloat = -0.14
            static let uppercaseLabel: CGFloat = 0.28
        }

        enum Line {
            static let title29: CGFloat = 29
            static let title288: CGFloat = 28.8
            static let body192: CGFloat = 19.2
            static let body224: CGFloat = 22.4
            static let body196: CGFloat = 19.6
            static let body20: CGFloat = 20
            static let body24: CGFloat = 24
            /// Calendar weekday abbrev row (Figma 1.2 × 10pt).
            static let calendarDayAbbrev: CGFloat = 12
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
        /// Neutral-tinted shadow in light; black with matched opacity in dark (`--color-shadow-neutral`).
        private static func shadowNeutral(_ lightAlpha: CGFloat, _ darkAlpha: CGFloat) -> Color {
            Color(UIColor { tc in
                if tc.userInterfaceStyle == .dark {
                    return UIColor.black.withAlphaComponent(darkAlpha)
                }
                return UIColor(red: 94 / 255, green: 94 / 255, blue: 114 / 255, alpha: lightAlpha)
            })
        }

        static let sheet = ShadowToken(color: shadowNeutral(0.2, 0.38), radius: 28, x: 0, y: 4)
        static let floatingCircularButton = ShadowToken(color: shadowNeutral(0.4, 0.45), radius: 56, x: 0, y: 4.416)
        static let suggestionChip = ShadowToken(color: shadowNeutral(0.2, 0.32), radius: 56, x: 0, y: 4.416)
        static let dropdownCard = ShadowToken(color: shadowNeutral(0.2, 0.35), radius: 56, x: 0, y: 4.416)

        /// Light mode carousel card shadow.
        static func dayCard(isActive: Bool) -> ShadowToken {
            ShadowToken(
                color: shadowNeutral(isActive ? 0.2 : 0.08, isActive ? 0.22 : 0.12),
                radius: isActive ? 56 : 36,
                x: 0,
                y: 2
            )
        }

        /// Figma dark (263:3329): `0px 2px 72px rgba(0,0,0,0.29)`.
        static let dayCardDark = ShadowToken(color: Color.black.opacity(0.29), radius: 72, x: 0, y: 2)

        static let ctaOuter = ShadowToken(color: shadowNeutral(0.3, 0.4), radius: 1.25, x: 0, y: 1)

        static let photoLabelText = ShadowToken(color: Overlay.black022, radius: 3, x: 0, y: 1)
        static let glassDark = ShadowToken(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
        static let glassLight = ShadowToken(color: Overlay.white035, radius: 8, x: 0, y: -1)

        /// Calendar habit shell (white card) — Figma drop shadow: `#5E5E72` @ 24%, blur 72, y 2, x 0, spread 4 (spread N/A in SwiftUI).
        static let calendarShellCard = ShadowToken(
            color: Color(UIColor { tc in
                let rgb = UIColor(red: 94 / 255, green: 94 / 255, blue: 114 / 255, alpha: 1)
                if tc.userInterfaceStyle == .dark {
                    return rgb.withAlphaComponent(0.32)
                }
                return rgb.withAlphaComponent(0.24)
            }),
            radius: 72,
            x: 0,
            y: 2
        )
        /// Dashed photo frame on calendar (Figma soft lift).
        static let calendarPhotoFrame = ShadowToken(color: shadowNeutral(0.08, 0.14), radius: 56, x: 0, y: 2)
        /// Selected day chip (Figma `0px 1px 2px` @ 40%).
        static let calendarDayChipSelected = ShadowToken(color: shadowNeutral(0.4, 0.35), radius: 2, x: 0, y: 1)
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
        static let homeAddButtonSize: CGFloat = 40
        /// Vertical gap from home header bottom to card carousel top (Figma 429:943).
        static let homeHeaderToCard: CGFloat = 56
        static let patternDotSpacing: CGFloat = 22
        static let patternDotRadius: CGFloat = 1.2
        static let patternDotOpacity: Double = 0.10
        static let splashLogoSize: CGFloat = 120
        static let glassBarHeight: CGFloat = 56
        /// Calendar habit card width on 402pt artboard (Figma 386:3156).
        static let calendarCardWidth: CGFloat = 362
        /// Day chip row cell height and width (Figma — fixed 48×48 cells).
        static let calendarDayChipHeight: CGFloat = 48
        static let calendarDayChipWidth: CGFloat = 48
        /// Inner dashed photo target height (Figma 389:5194).
        static let calendarPhotoFrameHeight: CGFloat = 351
        /// White inner shadow on photo frame when a tag is selected (`innerInsetRim`).
        static let calendarPhotoInnerShadowLineWidth: CGFloat = 2.5
        static let calendarPhotoInnerShadowBlur: CGFloat = 2
        static let calendarPhotoInnerShadowOffsetY: CGFloat = 1.1
        /// Selected tag inner shadow — `innerInsetRim` maps spread → line width (Figma spread 2, blur 9.5, offset 0).
        static let calendarPlaceholderPillTagInnerShadowSpread: CGFloat = 2
        static let calendarPlaceholderPillTagInnerShadowBlur: CGFloat = 9.5
        static let calendarPlaceholderPillTagInnerShadowOffsetX: CGFloat = 0
        static let calendarPlaceholderPillTagInnerShadowOffsetY: CGFloat = 0
        /// Circular add control (Figma 389:5196).
        static let calendarAddOrbSize: CGFloat = 72
        /// Horizontal and vertical bars that make up the plus glyph inside the add-photo orb.
        static let calendarAddGlyphLength: CGFloat = 22
        static let calendarAddGlyphThickness: CGFloat = 2
        /// Wheel date-picker sheet: grabber + nav + wheel + home indicator (tight; avoid extra bottom gap).
        static let calendarDateSheetDetentHeight: CGFloat = 320
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

// MARK: - UIColor hex (semantic dynamic colors)

extension UIColor {
    convenience init(hex: String) {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
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
