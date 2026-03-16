import SwiftUI

struct FrequencyOption: Identifiable, Equatable {
    let id: String
    let label: String
    let inlineLabel: String
    
    static let options = [
        FrequencyOption(id: "everyday", label: "Everyday", inlineLabel: "everyday."),
        FrequencyOption(id: "every_week", label: "Every week", inlineLabel: "every week."),
        FrequencyOption(id: "every_weekday", label: "Every weekday", inlineLabel: "every weekday."),
        FrequencyOption(id: "every_weekend", label: "Every weekend", inlineLabel: "every weekend."),
        FrequencyOption(id: "every_month", label: "Every month", inlineLabel: "every month."),
        FrequencyOption(id: "every_year", label: "Every year", inlineLabel: "every year.")
    ]
}

struct FrequencyBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedOption: FrequencyOption
    
    // Animation states
    @State private var sheetOffset: CGFloat = UIWindow.isLandscape ? 100 : 300 // Start below screen
    @State private var backdropOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if isPresented {
                // Dimmed Backdrop
                Color.black.opacity(0.2)
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSheet()
                    }
                
                // Sheet Content
                VStack(spacing: AppTheme.Spacing.xxl - 8) { // Closer to the 32 gap in RN
                    ForEach(FrequencyOption.options) { option in
                        Button(action: {
                            selectedOption = option
                            closeSheet()
                        }) {
                            Text(option.label)
                                .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.bgPrimary)
                .cornerRadius(AppTheme.Radius.xl)
                .shadow(color: AppTheme.Neutral._700.opacity(0.2), radius: 28, x: 0, y: 4) // Approximating elevation 16
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.18)) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }
    
    private func closeSheet() {
        withAnimation(.easeOut(duration: 0.18)) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        
        // Wait for animation to finish before removing from hierarchy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// Helper to determine landscape vs portrait for offset distances if needed
extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
