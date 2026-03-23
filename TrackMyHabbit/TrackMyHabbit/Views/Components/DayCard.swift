import PhotosUI
import SwiftUI
import SwiftData

struct DayCard: View {
    let dateStr: String
    let entry: HabitEntry?
    var isActive: Bool = true
    var cardWidth: CGFloat = 288
    var cardHeight: CGFloat = 397
    let tapAction: () -> Void
    let onImagePicked: (Data) -> Void

    var isEmpty: Bool { entry?.imageUri == nil }
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false

    var body: some View {
        cardContent
            .frame(width: cardWidth, height: cardHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                if isActive {
                    showPhotoPicker = true
                } else {
                    tapAction()
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }

                defer {
                    self.selectedPhoto = nil
                }

                if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    onImagePicked(data)
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
                .fill(AppTheme.Neutral._0)
                .appShadow(AppTheme.Elevation.dayCard(isActive: isActive))
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
                            .foregroundColor(AppTheme.Neutral._0)
                            .appShadow(AppTheme.Elevation.photoLabelText)

                        Text(DateUtils.getRelativeLabel(dateStr))
                            .customFont(.medium, size: AppTheme.Typography.Size.xs)
                            .foregroundColor(AppTheme.Neutral._0)
                            .appShadow(AppTheme.Elevation.photoLabelText)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md),
                    alignment: .bottomLeading
                )
            }
        }
        .background(AppTheme.Neutral._0)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                .stroke(isActive ? AppTheme.Neutral._0 : AppTheme.Colors.bgTertiary, lineWidth: AppTheme.Spacing.hairline)
        )
    }

    private var emptyCard: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
            .fill(
                isActive
                ? LinearGradient(
                    colors: [AppTheme.Colors.gradientDayCardStart, AppTheme.Neutral._0],
                    startPoint: .top,
                    endPoint: .bottom
                )
                : LinearGradient(
                    colors: [AppTheme.Neutral._0, AppTheme.Neutral._0],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .stroke(isActive ? AppTheme.Neutral._0 : AppTheme.Colors.bgTertiary, lineWidth: AppTheme.Spacing.hairline)
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
