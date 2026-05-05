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
        static let surfaceSelected = semantic("#e1e5ea", "#53555c")
        static let gradientDayCardStart = semantic("#e2e8ff", "#171717")
        static let gradientDayCardEnd = semantic("#ffffff", "#212121")

        static let dayCardFill = semantic("#ffffff", "#1a1a1a")
        static let borderSubtle = semantic("#e9e9ef", "#212121")
        static let chipBackground = semantic("#ffffff", "#2c2c2e")

        /// Calendar photo placeholder well (Figma 458:1799 — dark `#262626`).
        static let calendarPhotoPlaceholderFill = semantic("#ffffff", "#262626")

        /// Uppercase date + day row on calendar habit shell (Figma 458:1795 — neutral 600 `#53555c` dark).
        static let calendarCardMetaText = semantic("#8c95a6", "#53555c")

        /// Calendar shell card border (Figma neutral-200 `#eeeeee`; dark `#212121`).
        static let calendarShellBorder = semantic("#eeeeee", "#212121")
        /// Unselected horizontal day chip fill (`surfaceSelected` light; Figma 465:2014 dark `#262626`).
        static let calendarDayChipRestFill = semantic("#e1e5ea", "#262626")
        /// Unselected day chip label (Figma 465:2014 dark neutral `#9ea1a8`).
        static let calendarDayChipRestText = semantic("#5b6271", "#9ea1a8")
        /// Selected day chip fill (Figma neutral-950 `#18191b` light; Figma 465:2014 dark `#ffffff`).
        static let calendarDaySelectedFill = semantic("#18191b", "#ffffff")
        /// Hairline on selected day chip (Figma white ring; 465:2014 dark white border).
        static let calendarDaySelectedStroke = semantic("#ffffff", "#ffffff")
        /// Text on selected day chip (inverse on dark pill light; Figma 465:2014 dark `#16191d` on white).
        static let calendarDayChipSelectedLabel = semantic("#ffffff", "#16191d")
        /// Calendar header “11 April” title (Figma 465:2017 — white in dark).
        static let calendarDateHeaderText = semantic("#16191d", "#ffffff")
        /// Weekday header row ("SUN MON TUE …") above the month grid.
        static let calendarGridWeekdayText = semantic("#8c95a6", "#8e8e93")
        /// Today ring stroke on the month grid (mirrors selected day chip fill).
        static let calendarGridTodayRing = semantic("#18191b", "#ffffff")
        /// Dimmed scrim behind the tap-open calendar card overlay (Figma 365:173 — pairs with blur material).
        static let calendarOverlayScrim = semantic(
            UIColor(white: 0, alpha: 0.18),
            UIColor(white: 0, alpha: 0.32)
        )
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

        /// Contribution graph heat-map — binary active/inactive for the streak
        /// card (Figma 510:1864). `tier0` = no entry, `tier4` = entry logged.
        /// Intermediate tiers retained for future tiered visualisations; keep
        /// raw sRGB so `UIColor` dynamic resolution does not wash out fills.
        enum Heatmap {
            static let lightTier0 = Color(hex: "#E0E0E0")
            static let lightTier1 = Color(hex: "#DCF3DD")
            static let lightTier2 = Color(hex: "#ADEAB7")
            static let lightTier3 = Color(hex: "#7BDB86")
            static let lightTier4 = Color(hex: "#15D38A")
            static let darkTier0 = Color(hex: "#262626")
            static let darkTier1 = Color(hex: "#0E4429")
            static let darkTier2 = Color(hex: "#006D32")
            static let darkTier3 = Color(hex: "#26A641")
            static let darkTier4 = Color(hex: "#39D353")
        }

        /// Home wallet day-card border (Figma 604:2497 — `var(--neutral/neutral-[200], #eee)`).
        static let walletCardBorder = semantic("#eeeeee", "#212121")

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
        /// Horizontal gap between habit day cards in home + calendar `ScrollView` (was `sm` 8pt).
        static let horizontalHabitCardGap: CGFloat = 12
        /// Add-photo orb ↔ title (Figma 389:5195).
        static let calendarAddOrbTitle: CGFloat = 11
        /// Top inset for the centered empty-photo CTA stack (Figma 389:5195).
        static let calendarPlaceholderTopInset: CGFloat = 124
        /// Vertical inset so day-chip drop shadows are not clipped by the parent scroll view (Figma dev).
        static let calendarChipStripShadowBleed: CGFloat = 16
        /// Inset around calendar habit cards inside horizontal `ScrollView` so shell blur 72 is not clipped (Figma drop shadow).
        static let calendarHabitCardShadowBleed: CGFloat = 80
        /// Visible vertical gap between the calendar habit card row and the contribution graph card below it.
        static let calendarHabitCardToGraphGap: CGFloat = 40
        /// Horizontal gap between cells in the month grid (Figma 510:1543 `gap-x-[4px]`).
        static let calendarGridCellGap: CGFloat = 4
        /// Vertical gap between rows in the month grid (Figma 510:1543 `gap-y-[8px]`).
        static let calendarGridRowGap: CGFloat = 8
        /// Combined gap from weekday header baseline to first grid row (2pt outer + 8pt inner per Figma 510:1691).
        static let calendarGridWeekdayToGrid: CGFloat = 10
        /// Gap from the calendar date title row to the month grid weekday header.
        static let calendarGridHeaderToGrid: CGFloat = 20
        /// Gap below the month grid before the contribution graph card.
        static let calendarGridToGraphGap: CGFloat = 32

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
            /// Streak hero digit on contribution card (Figma 510:2100 — Season Mix 64pt).
            static let streakHero: CGFloat = 64
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
            /// Home wallet day-card date row "20TH MARCH, 2026" (Figma 604:2504 — `+0.24`).
            static let walletCardDate: CGFloat = 0.24
            /// Home wallet day-card status pill "UPCOMING / TOMORROW / TODAY" (Figma 604:2528 — `+1.44`).
            static let walletStatusPill: CGFloat = 1.44
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

        /// Wallet expand spring (enter). Slightly slower than the dismiss so the
        /// expansion reads as deliberate; Apple's `duration:bounce:` form is
        /// preferred per design-eng for being easier to reason about.
        static let springWalletPin = Animation.spring(duration: 0.7, bounce: 0.2)
        /// Wallet dismiss spring (exit). Snappier than `springWalletPin` so the
        /// system feels responsive to the user leaving the detail state — the
        /// asymmetric enter/exit pattern (exit faster than enter) per design-eng.
        static let springWalletUnpin = Animation.spring(duration: 0.55, bounce: 0.18)
        /// Snap-back spring when a drag-to-dismiss release falls short of the
        /// threshold. Short and crisp so the card re-pins immediately.
        static let springWalletDragCancel = Animation.spring(duration: 0.35, bounce: 0.15)
        /// Strong ease-out (cubic-bezier(0.23, 1, 0.32, 1) per design-eng).
        /// Built-in `.easeOut` is too weak — this curve has the punch that
        /// makes UI animations feel intentional. Used for the unselected-card
        /// fade-out on expand: opacity must hit 0 well before the spring
        /// carries the card past the screen edge.
        static var easeWalletCardFadeOut: Animation { .timingCurve(0.23, 1, 0.32, 1, duration: 0.22) }
        /// Same strong ease-out, duration matched to `springWalletUnpin` so
        /// unselected cards become fully visible right as they settle back
        /// into the stack. Note: deliberately ease-out, NOT ease-in — ease-in
        /// is sluggish and forbidden by the design-eng guidelines.
        static var easeWalletCardFadeIn: Animation { .timingCurve(0.23, 1, 0.32, 1, duration: 0.55) }
        /// Backdrop opacity fade (enter and exit). Strong custom ease-out for
        /// instant perceived feedback on both directions of the transition.
        static var easeWalletBackdrop: Animation { .timingCurve(0.23, 1, 0.32, 1, duration: 0.4) }
    }

    // MARK: - Gradients

    /// SwiftUI often renders `LinearGradient` as a flat fill when stops use dynamic semantic `Color` (UIKit-resolved).
    /// Use fixed sRGB hex stops (mirroring `gradientDayCardStart` / `gradientDayCardEnd`) so the blend interpolates reliably.
    enum Gradients {
        /// Home `DayCard` empty shell + calendar habit shell — vertical `#171717` → `#212121` (dark), `#e2e8ff` → `#ffffff` (light).
        static func dayCardShell(colorScheme: ColorScheme) -> LinearGradient {
            let isDark = colorScheme == .dark
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(hex: isDark ? "#171717" : "#e2e8ff"), location: 0),
                    Gradient.Stop(color: Color(hex: isDark ? "#212121" : "#ffffff"), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        /// Inactive home stack card: flat fill matching `gradientDayCardEnd` (dark / light).
        static func dayCardInactiveFill(colorScheme: ColorScheme) -> LinearGradient {
            let end = Color(hex: colorScheme == .dark ? "#212121" : "#ffffff")
            return LinearGradient(colors: [end, end], startPoint: .top, endPoint: .bottom)
        }

        /// Calendar habit shell: same vertical gradient as `dayCardShell` in dark; in light, flat `#ffffff` (no `#e2e8ff` top wash).
        static func calendarHabitShell(colorScheme: ColorScheme) -> LinearGradient {
            if colorScheme == .dark {
                return dayCardShell(colorScheme: colorScheme)
            }
            let white = Color(hex: "#ffffff")
            return LinearGradient(colors: [white, white], startPoint: .top, endPoint: .bottom)
        }
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

        /// Calendar habit shell — dark: black @ 29%. Light: neutral black (no `#5E5E72` cast; that hue read as a blue/lavender halo behind the card).
        static let calendarShellCard = ShadowToken(
            color: Color(UIColor { tc in
                if tc.userInterfaceStyle == .dark {
                    return UIColor(red: 0, green: 0, blue: 0, alpha: 0.29)
                }
                return UIColor(white: 0, alpha: 0.16)
            }),
            radius: 36,
            x: 0,
            y: 2
        )
        /// Dashed photo frame on calendar / home — dark: black @ 14%. Light: neutral black (same reason as `calendarShellCard`).
        static let calendarPhotoFrame = ShadowToken(
            color: Color(UIColor { tc in
                if tc.userInterfaceStyle == .dark {
                    return UIColor.black.withAlphaComponent(0.14)
                }
                return UIColor(white: 0, alpha: 0.10)
            }),
            radius: 56,
            x: 0,
            y: 2
        )
        /// Selected day chip (Figma `0px 1px 2px` @ 40%).
        static let calendarDayChipSelected = ShadowToken(color: shadowNeutral(0.4, 0.35), radius: 2, x: 0, y: 1)
        /// Calendar empty-state collage photo tile (Figma `0px 1.68px 60.471px rgba(0,0,0,0.12)`).
        static let calendarCollagePhoto = ShadowToken(color: Color.black.opacity(0.12), radius: 60.471, x: 0, y: 1.68)
        /// Home wallet day-card outer shadow — deliberately softer than Figma's
        /// web-export blur so expanded cards do not grow a gray bottom shelf.
        static let walletDayCard = ShadowToken(
            color: shadowNeutral(0.05, 0.18),
            radius: 24,
            x: 0,
            y: 2
        )
        /// Pinned (detail-view) wallet card — Apple Wallet-style ambient drop
        /// shadow that lifts the card off the flat backdrop. Wider radius and
        /// larger Y offset than the stack-state shadow to give the "floating"
        /// feel of a Wallet pass on its detail screen.
        static let walletDayCardPinned = ShadowToken(
            color: shadowNeutral(0.18, 0.42),
            radius: 32,
            x: 0,
            y: 10
        )

        /// Home wallet empty photo frame (Figma 604:2704 — `0 1.534 27.615 rgba(94,94,114,0.08)`).
        static let walletPhotoFrame = ShadowToken(
            color: shadowNeutral(0.08, 0.14),
            radius: 27.615,
            x: 0,
            y: 2
        )

        /// Contribution graph card shadow (Figma 483:2160 — `0px 2px 72px rgba(94,94,114,0.32)`).
        static let contributionGraphCard = ShadowToken(
            color: Color(UIColor { tc in
                if tc.userInterfaceStyle == .dark {
                    return UIColor.black.withAlphaComponent(0.32)
                }
                return UIColor(red: 94 / 255, green: 94 / 255, blue: 114 / 255, alpha: 0.32)
            }),
            radius: 72,
            x: 0,
            y: 2
        )
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
        /// Calendar empty-state photo collage tile size (Figma 458:1584 — 83.689pt square).
        static let calendarCollagePhotoSize: CGFloat = 83.689
        /// Calendar empty-state photo collage corner radius (Figma 13.438pt).
        static let calendarCollagePhotoRadius: CGFloat = 13.438
        /// Calendar empty-state photo collage border width (Figma 1.68pt white).
        static let calendarCollageBorderWidth: CGFloat = 1.68
        /// Calendar empty-state collage container height (Figma 458:1620 — 110pt).
        static let calendarCollageHeight: CGFloat = 110
        /// Calendar empty-state collage container width (Figma 458:1620 — 168pt).
        static let calendarCollageWidth: CGFloat = 168
        /// Calendar empty-state "Add habit" CTA width (Figma 458:1582 — 131pt).
        static let calendarEmptyCTAWidth: CGFloat = 131
        /// Calendar empty-state "Add habit" CTA height (Figma 458:1582 — 54pt).
        static let calendarEmptyCTAHeight: CGFloat = 54
        /// Wheel date-picker sheet: grabber + nav + wheel + home indicator (tight; avoid extra bottom gap).
        static let calendarDateSheetDetentHeight: CGFloat = 320
        static let photoGradientHeight: CGFloat = 80
        static let photoOverlayOpacity: Double = 0.18
        static let placeholderGray: Double = 0.3
        static let logoStrokeWidth: CGFloat = 0.2
        static let logoInnerBlur: CGFloat = 1
        static let logoInnerOffsetY: CGFloat = -1.5
        static let logoInnerStrokeWidth: CGFloat = 3
        /// Height reserved in the scroll view for the floating calendar date-title row.
        /// Equals the title content height below `Spacing.md` (`"15 April" 24pt SeasonMix`).
        static let calendarTitleContentHeight: CGFloat = 32
        /// Extra fade region below the title for the progressive-blur mask.
        static let calendarTitleBlurFadeHeight: CGFloat = 24
        /// Streak hero fire glyph (Figma 510:2099 — 64pt square container).
        static let streakFireIconSize: CGFloat = 64
        /// SF Symbol point size inside the 64pt fire container.
        static let streakFireSymbolSize: CGFloat = 44
        /// Contribution graph: cell square size (Figma 485:1279 — 20pt).
        static let heatmapCell: CGFloat = 20
        /// Contribution graph: cell corner radius (Figma 4pt).
        static let heatmapCellRadius: CGFloat = 4
        /// Contribution graph: minimum gap between cells; actual gap is computed to fill card width.
        static let heatmapMinGap: CGFloat = 4
        /// Contribution graph: columns per row (12 cells per row, `justify-between`).
        static let heatmapColumns: Int = 12
        /// Contribution graph: rows (7 rows of cells stacked vertically with 4pt gap — 84-day rolling window).
        static let heatmapRows: Int = 7
        /// Month grid columns (Sun…Sat).
        static let calendarGridColumns: Int = 7
        /// Corner radius for month grid day cells (matches existing day chip radius).
        static let calendarGridCellRadius: CGFloat = 12
        /// Today ring stroke width on the month grid.
        static let calendarGridTodayRingWidth: CGFloat = 1.5
        /// Close / menu button size on the tap-open overlay card (Figma 365:178, 365:186 — 48×48).
        static let calendarOverlayChromeButton: CGFloat = 48
        /// Top inset from safe-area top for the floating overlay card (Figma 365:173 — `padding-top: 40`).
        static let calendarOverlayCardTopInset: CGFloat = 40

        /// Home wallet stack — Apple Wallet-style stacked day cards (Figma 604:1934).
        /// Negative VStack spacing so peeking cards show only ~51pt of their header.
        static let walletDayCardOverlap: CGFloat = -400
        /// Off-screen push padding when a card is selected (others slide away).
        static let walletPushPadding: CGFloat = 300
        /// Vertical offset of the pinned (selected) card from the scroll view top.
        static let walletSelectedTopInset: CGFloat = 20
        /// Bottom inset reserved below the stack so the last card isn't clipped
        /// by the tab bar / frosted blur strip.
        static let walletBottomInset: CGFloat = 200
        /// Bottom progressive-blur strip height — short enough to cover only the
        /// tab bar zone so it doesn't fade the bottom of today's card.
        static let walletBottomBlurHeight: CGFloat = 60
        /// Top progressive-blur strip height (sits behind the HabitSwitcher and
        /// feathers content scrolling underneath the safe area).
        static let walletTopBlurHeight: CGFloat = 60
        /// Number of upcoming days rendered above today in the home wallet stack.
        static let walletUpcomingDayCount: Int = 6
        /// Status pill horizontal padding (Figma 604:2525 — px 8).
        static let walletStatusPillHPadding: CGFloat = 8
        /// Status pill vertical padding (Figma 604:2525 — py 4).
        static let walletStatusPillVPadding: CGFloat = 4
        /// Drag distance below which the pinned wallet card snaps back instead of dismissing.
        static let walletDragDismissThreshold: CGFloat = 120
        /// Predicted-translation threshold for flick-to-dismiss on the pinned wallet card.
        static let walletDragFlickThreshold: CGFloat = 240
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
        /// Future month-grid days are read-only — visually muted to signal "not yet available".
        static let calendarFutureDay: Double = 0.35
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
