import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct HomeDayCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let habit: Habit
    let dateStr: String
    let cardWidth: CGFloat
    let effectiveToday: Date
    let onImagePicked: (Data) -> Void

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var selectedPlaceholderTagID: String?

    private var entry: HabitEntry? {
        habit.entries.first(where: { $0.dateString == dateStr })
    }

    private var hasPhoto: Bool {
        entry?.imageUri != nil
    }

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        c.locale = .current
        return c
    }

    private var addPhotoTitle: String {
        guard let date = DateUtils.parseDate(dateStr) else { return "Add photo" }
        return calendar.isDate(date, inSameDayAs: effectiveToday)
            ? "Add today's photo"
            : "Add photo"
    }

    private var dayNumber: Int {
        DateUtils.dayNumber(createdAt: habit.createdAt, dateStr: dateStr)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            titleSection
            photoFrame
            placeholderPillRow
        }
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .frame(width: cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .fill(AppTheme.Gradients.calendarHabitShell(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .inset(by: 0.5)
                .stroke(AppTheme.Colors.calendarShellBorder, lineWidth: AppTheme.Spacing.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous))
        .appShadow(AppTheme.Elevation.calendarShellCard)
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            defer { self.selectedPhoto = nil }
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                onImagePicked(data)
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(habit.name)
                .customFont(
                    .serifsemibold,
                    size: AppTheme.Typography.Size.lg,
                    lineHeight: AppTheme.Typography.Line.body24,
                    tracking: AppTheme.Typography.Tracking.nav
                )
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.sm) {
                Text(DateUtils.formatDateWithOrdinal(dateStr))
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.sm,
                        tracking: AppTheme.Typography.Tracking.uppercaseLabel
                    )
                    .foregroundColor(AppTheme.Colors.calendarCardMetaText)
                    .textCase(.uppercase)

                Circle()
                    .fill(AppTheme.Colors.calendarCardMetaText)
                    .frame(width: 4, height: 4)

                Text("DAY \(dayNumber)")
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.sm,
                        tracking: AppTheme.Typography.Tracking.uppercaseLabel
                    )
                    .foregroundColor(AppTheme.Colors.calendarCardMetaText)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Photo Frame

    private var photoFrame: some View {
        Group {
            if hasPhoto {
                photoContent
            } else {
                emptyPhotoContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: AppTheme.Layout.calendarPhotoFrameHeight)
        .background(AppTheme.Colors.calendarPhotoPlaceholderFill)
        .clipShape(photoClipShape)
        .overlay {
            if !hasPhoto {
                photoClipShape
                    .stroke(
                        AppTheme.Colors.surfaceSelected,
                        style: StrokeStyle(lineWidth: AppTheme.Spacing.hairline, dash: [6, 5])
                    )
            }
        }
        .modifier(
            HomePhotoInnerShadowModifier(
                isActive: selectedPlaceholderTagID != nil,
                cornerRadius: AppTheme.Radius.xl
            )
        )
        .appShadow(AppTheme.Elevation.calendarPhotoFrame)
        .contentShape(Rectangle())
        .onTapGesture {
            showPhotoPicker = true
        }
    }

    private var photoClipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
    }

    @ViewBuilder
    private var photoContent: some View {
        if let uri = entry?.imageUri, let url = URL(string: uri) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    AppTheme.Overlay.grayPhotoPlaceholder
                case let .success(image):
                    image.resizable().scaledToFill()
                case .failure:
                    AppTheme.Overlay.grayPhotoPlaceholder
                @unknown default:
                    AppTheme.Overlay.grayPhotoPlaceholder
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(AppTheme.Colors.bgPrimary)
            .clipped()
            .contentShape(Rectangle())
        } else {
            AppTheme.Overlay.grayPhotoPlaceholder
        }
    }

    private var emptyPhotoContent: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: AppTheme.Spacing.calendarPlaceholderTopInset)
            VStack(spacing: AppTheme.Spacing.calendarAddOrbTitle) {
                HomeAddPhotoOrb()
                    .frame(
                        width: AppTheme.Layout.calendarAddOrbSize,
                        height: AppTheme.Layout.calendarAddOrbSize
                    )
                Text(addPhotoTitle)
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.md,
                        lineHeight: AppTheme.Typography.Line.body192,
                        tracking: AppTheme.Typography.Tracking.tight
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(addPhotoTitle)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Placeholder Pills

    private var placeholderPillRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(placeholderPills, id: \.id) { pill in
                let isSelected = selectedPlaceholderTagID == pill.id
                Button {
                    withAnimation(AppTheme.Motion.easeTab) {
                        if selectedPlaceholderTagID == pill.id {
                            selectedPlaceholderTagID = nil
                        } else {
                            selectedPlaceholderTagID = pill.id
                        }
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(pill.title)
                        .customFont(
                            .medium,
                            size: AppTheme.Typography.Size.xs,
                            lineHeight: AppTheme.Typography.Line.body192,
                            tracking: AppTheme.Typography.Tracking.calendarHabitChip
                        )
                        .foregroundColor(pill.textColor)
                        .lineLimit(1)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(pillBackground(pill: pill, isSelected: isSelected))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var placeholderPills: [HomePlaceholderPill] {
        [
            .init(
                title: "Personal",
                fillColor: AppTheme.Colors.calendarPlaceholderPillBlueFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillBlueFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillBlueText
            ),
            .init(
                title: "Study",
                fillColor: AppTheme.Colors.calendarPlaceholderPillOrangeFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillOrangeFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillOrangeText
            ),
            .init(
                title: "Health",
                fillColor: AppTheme.Colors.calendarPlaceholderPillGreenFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillGreenFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillGreenText
            ),
        ]
    }

    @ViewBuilder
    private func pillBackground(pill: HomePlaceholderPill, isSelected: Bool) -> some View {
        let capsule = Capsule(style: .continuous)
        if isSelected {
            capsule
                .fill(pill.selectedFillColor)
                .innerInsetRim(
                    shape: capsule,
                    color: AppTheme.Colors.calendarPlaceholderPillTagInnerShadow,
                    lineWidth: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowSpread,
                    blur: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowBlur,
                    offsetX: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowOffsetX,
                    offsetY: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowOffsetY
                )
        } else {
            capsule.fill(pill.fillColor)
        }
    }
}

// MARK: - Supporting Types

private struct HomePlaceholderPill: Identifiable {
    let title: String
    let fillColor: Color
    let selectedFillColor: Color
    let textColor: Color
    var id: String { title }
}

private struct HomePhotoInnerShadowModifier: ViewModifier {
    let isActive: Bool
    let cornerRadius: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if isActive {
            content
                .innerInsetRim(
                    shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
                    color: AppTheme.Colors.calendarPhotoSelectedInnerShadow,
                    lineWidth: AppTheme.Layout.calendarPhotoInnerShadowLineWidth,
                    blur: AppTheme.Layout.calendarPhotoInnerShadowBlur,
                    offsetX: 0,
                    offsetY: AppTheme.Layout.calendarPhotoInnerShadowOffsetY
                )
        } else {
            content
        }
    }
}

// MARK: - Add Photo Orb

private struct HomeAddPhotoOrb: View {
    private let navyRimY: CGFloat = 3.45
    private let navyRimLineWidth: CGFloat = 5.5
    private let navyRimAccentY: CGFloat = 0.42
    private let navyRimAccentWidth: CGFloat = 2.2
    private let lightRimOffsetY: CGFloat = 2.05
    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36
    private let hairline: CGFloat = 0.5

    var body: some View {
        ZStack {
            ctaCircleBackground
            HomeAddPhotoGlyph()
        }
        .compositingGroup()
        .appShadow(AppTheme.Elevation.ctaOuter)
    }

    private var ctaCircleBackground: some View {
        let shape = Circle()
        return shape
            .fill(figmaGradient)
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Colors.ctaInsetNavy.opacity(0.2),
                lineWidth: navyRimLineWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimY
            )
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Overlay.black020,
                lineWidth: navyRimAccentWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimAccentY
            )
            .innerInsetRim(
                shape: shape,
                color: Color.white.opacity(bottomLightRimOpacity),
                lineWidth: bottomLightRimWidth,
                blur: 0,
                offsetX: 0,
                offsetY: lightRimOffsetY
            )
            .overlay(
                shape.stroke(AppTheme.Colors.ctaHairline, lineWidth: hairline)
            )
    }

    private var figmaGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: AppTheme.Colors.emptyStateCTAStart, location: 0),
                .init(color: AppTheme.Colors.emptyStateCTAMid, location: 0.85222),
                .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1.5556)
        )
    }
}

private struct HomeAddPhotoGlyph: View {
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphLength,
                    height: AppTheme.Layout.calendarAddGlyphThickness
                )
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphThickness,
                    height: AppTheme.Layout.calendarAddGlyphLength
                )
        }
        .frame(
            width: AppTheme.Typography.Size.calendarPlusGlyph,
            height: AppTheme.Typography.Size.calendarPlusGlyph
        )
    }
}
