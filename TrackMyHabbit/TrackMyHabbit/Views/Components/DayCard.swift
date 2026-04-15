import SwiftUI
import SwiftData

struct DayCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let dateStr: String
    let entry: HabitEntry?
    var isActive: Bool = true
    var cardWidth: CGFloat = 288
    var cardHeight: CGFloat = 397
    let tapAction: () -> Void
    let onImagePicked: (Data) -> Void

    var isEmpty: Bool { entry?.imageUri == nil }
    @Environment(PhotoSourceController.self) private var photoSource

    private var cardShadow: AppTheme.ShadowToken {
        if colorScheme == .dark {
            return AppTheme.Elevation.dayCardDark
        }
        return AppTheme.Elevation.dayCard(isActive: isActive)
    }

    private var emptyStrokeColor: Color {
        if colorScheme == .dark {
            return AppTheme.Colors.borderSubtle
        }
        return isActive ? AppTheme.Colors.textInverse : AppTheme.Colors.bgTertiary
    }

    private var photoStrokeColor: Color {
        if colorScheme == .dark {
            return AppTheme.Colors.borderSubtle
        }
        return isActive ? AppTheme.Colors.textInverse : AppTheme.Colors.bgTertiary
    }

    var body: some View {
        cardContent
            .frame(width: cardWidth, height: cardHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                if isActive {
                    photoSource.present(onImagePicked: onImagePicked)
                } else {
                    tapAction()
                }
            }
    }

    private var cardContent: some View {
        ZStack {
            if !isEmpty {
                photoCard
            } else {
                emptyCard
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                .fill(AppTheme.Colors.dayCardFill)
                .appShadow(cardShadow)
        )
    }

    private var photoCard: some View {
        GeometryReader { proxy in
            if let uri = entry?.imageUri, let url = URL(string: uri) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    AppTheme.Overlay.grayPhotoPlaceholder
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            } else {
                AppTheme.Overlay.grayPhotoPlaceholder
            }

            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, AppTheme.Overlay.black018],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: AppTheme.Layout.photoGradientHeight)
                .overlay(
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(DateUtils.formatDate(dateStr))
                            .customFont(isActive ? .semibold : .medium, size: isActive ? AppTheme.Typography.Size.md : AppTheme.Typography.Size.sm, tracking: isActive ? AppTheme.Typography.Tracking.body : 0)
                            .foregroundColor(AppTheme.Colors.textInverse)
                            .appShadow(AppTheme.Elevation.photoLabelText)

                        Text(DateUtils.getRelativeLabel(dateStr))
                            .customFont(.medium, size: AppTheme.Typography.Size.xs)
                            .foregroundColor(AppTheme.Colors.textInverse)
                            .appShadow(AppTheme.Elevation.photoLabelText)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md),
                    alignment: .bottomLeading
                )
            }
        }
        .background(AppTheme.Colors.dayCardFill)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                .stroke(photoStrokeColor, lineWidth: AppTheme.Spacing.hairline)
        )
    }

    private var emptyCard: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
            .fill(
                isActive
                    ? AppTheme.Gradients.dayCardShell(colorScheme: colorScheme)
                    : AppTheme.Gradients.dayCardInactiveFill(colorScheme: colorScheme)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .stroke(emptyStrokeColor, lineWidth: AppTheme.Spacing.hairline)
            )
            .overlay(alignment: .topLeading) {
                HStack(spacing: isActive ? AppTheme.Spacing.sm : AppTheme.Layout.habitChipSpacing) {
                    Image(systemName: "plus")
                        .font(.system(size: AppTheme.Typography.Size.md, weight: .semibold))

                    Text("Add photo")
                        .customFont(.semibold, size: AppTheme.Typography.Size.md, lineHeight: AppTheme.Typography.Line.body224, tracking: AppTheme.Typography.Tracking.tight)
                }
                .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                .padding(AppTheme.Spacing.lg)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(DateUtils.formatDate(dateStr))
                        .customFont(isActive ? .semibold : .medium, size: isActive ? AppTheme.Typography.Size.md : AppTheme.Typography.Size.sm, lineHeight: isActive ? AppTheme.Typography.Line.body224 : AppTheme.Typography.Line.body196, tracking: isActive ? AppTheme.Typography.Tracking.body : 0)
                    Text(DateUtils.getRelativeLabel(dateStr))
                        .customFont(.medium, size: AppTheme.Typography.Size.xs)
                }
                .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                .padding(AppTheme.Spacing.lg)
            }
    }
}
