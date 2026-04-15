import SwiftUI

// MARK: - Frequency Option Model

struct FrequencyOption: Identifiable, Equatable {
    let id: String
    let label: String
    
    /// Returns the inline label based on current sub-selections
    func inlineLabel(dayOfWeek: DayOfWeek?, dayOfMonth: Int?, monthOfYear: MonthOfYear?) -> String {
        switch id {
        case "everyday":
            return "everyday."
        case "every_week":
            let dayName = dayOfWeek?.name.lowercased() ?? "monday"
            return "every week, on"
        case "every_weekday":
            return "every weekday."
        case "every_weekend":
            return "every weekend."
        case "every_month":
            let dateSuffix = ordinalSuffix(for: dayOfMonth ?? 1)
            return "every month, on the"
        case "every_year":
            let month = monthOfYear?.name ?? "January"
            let dateSuffix = ordinalSuffix(for: dayOfMonth ?? 1)
            return "every year, on"
        default:
            return label.lowercased()
        }
    }
    
    /// Does this frequency need a day-of-week sub-selection?
    var needsDayOfWeek: Bool { id == "every_week" }
    /// Does this frequency need a day-of-month sub-selection?
    var needsDayOfMonth: Bool { id == "every_month" || id == "every_year" }
    /// Does this frequency need a month sub-selection?
    var needsMonth: Bool { id == "every_year" }
    
    /// Simple inline label (no sub-selections needed)
    var simpleInlineLabel: String {
        switch id {
        case "everyday": return "everyday."
        case "every_weekday": return "every weekday."
        case "every_weekend": return "every weekend."
        default: return label.lowercased() + "."
        }
    }
    
    static let options = [
        FrequencyOption(id: "everyday", label: "Everyday"),
        FrequencyOption(id: "every_week", label: "Every week"),
        FrequencyOption(id: "every_weekday", label: "Every weekday"),
        FrequencyOption(id: "every_weekend", label: "Every weekend"),
        FrequencyOption(id: "every_month", label: "Every month"),
        FrequencyOption(id: "every_year", label: "Every year")
    ]
}

// MARK: - Day of Week

enum DayOfWeek: Int, CaseIterable, Identifiable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}

// MARK: - Month of Year

enum MonthOfYear: Int, CaseIterable, Identifiable {
    case january = 1, february, march, april, may, june
    case july, august, september, october, november, december
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        }
    }
}

// MARK: - Ordinal Suffix Helper

func ordinalSuffix(for day: Int) -> String {
    let suffixes = ["th", "st", "nd", "rd"]
    let remainder = day % 100
    let suffix: String
    if (11...13).contains(remainder) {
        suffix = "th"
    } else if remainder % 10 < 4 {
        suffix = suffixes[remainder % 10]
    } else {
        suffix = "th"
    }
    return "\(day)\(suffix)"
}

// MARK: - Frequency Bottom Sheet (Main frequency picker)

struct FrequencyBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedOption: FrequencyOption
    
    // Animation states
    @State private var sheetOffset: CGFloat = UIWindow.isLandscape ? 100 : 300
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
                VStack(spacing: AppTheme.Spacing.xxl - 8) {
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
                .background(AppTheme.Colors.bgSecondary)
                .cornerRadius(AppTheme.Radius.xl)
                .appShadow(AppTheme.Elevation.sheet)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(AppTheme.Motion.easeSheetIn) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }
    
    private func closeSheet() {
        withAnimation(AppTheme.Motion.easeSheetOut) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// MARK: - Day of Week Bottom Sheet

struct DayOfWeekBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDay: DayOfWeek
    
    @State private var sheetOffset: CGFloat = 300
    @State private var backdropOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.2)
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSheet()
                    }
                
                VStack(spacing: AppTheme.Spacing.xxl - 8) {
                    ForEach(DayOfWeek.allCases) { day in
                        Button(action: {
                            selectedDay = day
                            closeSheet()
                        }) {
                            Text(day.name)
                                .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.bgSecondary)
                .cornerRadius(AppTheme.Radius.xl)
                .appShadow(AppTheme.Elevation.sheet)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(AppTheme.Motion.easeSheetIn) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }
    
    private func closeSheet() {
        withAnimation(AppTheme.Motion.easeSheetOut) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// MARK: - Day of Month Bottom Sheet (Scrollable, 1st–31st)

struct DayOfMonthBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDay: Int
    
    @State private var sheetOffset: CGFloat = 300
    @State private var backdropOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.2)
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSheet()
                    }
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.xxl - 8) {
                            ForEach(1...31, id: \.self) { day in
                                Button(action: {
                                    selectedDay = day
                                    closeSheet()
                                }) {
                                    Text(ordinalSuffix(for: day))
                                        .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.lg)
                    }
                }
                .frame(maxHeight: 320)
                .background(AppTheme.Colors.bgSecondary)
                .cornerRadius(AppTheme.Radius.xl)
                .appShadow(AppTheme.Elevation.sheet)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(AppTheme.Motion.easeSheetIn) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }
    
    private func closeSheet() {
        withAnimation(AppTheme.Motion.easeSheetOut) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// MARK: - Month Picker Bottom Sheet

struct MonthPickerBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedMonth: MonthOfYear
    
    @State private var sheetOffset: CGFloat = 300
    @State private var backdropOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.2)
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSheet()
                    }
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.xxl - 8) {
                            ForEach(MonthOfYear.allCases) { month in
                                Button(action: {
                                    selectedMonth = month
                                    closeSheet()
                                }) {
                                    Text(month.name)
                                        .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.lg)
                    }
                }
                .frame(maxHeight: 320)
                .background(AppTheme.Colors.bgSecondary)
                .cornerRadius(AppTheme.Radius.xl)
                .appShadow(AppTheme.Elevation.sheet)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(AppTheme.Motion.easeSheetIn) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }
    
    private func closeSheet() {
        withAnimation(AppTheme.Motion.easeSheetOut) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

// MARK: - Photo Source Bottom Sheet (Gallery vs. Camera)

struct PhotoSourceBottomSheet: View {
    @Binding var isPresented: Bool
    var onSelectGallery: () -> Void
    var onSelectCamera: () -> Void

    @State private var sheetOffset: CGFloat = UIWindow.isLandscape ? 100 : 300
    @State private var backdropOpacity: Double = 0

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.3)
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSheet()
                    }

                VStack(spacing: AppTheme.Spacing.xxl - 8) {
                    Button(action: {
                        closeSheet(then: onSelectGallery)
                    }) {
                        Text("Upload from gallery")
                            .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button(action: {
                        closeSheet(then: onSelectCamera)
                    }) {
                        Text("Take a photo")
                            .customFont(.semibold, size: AppTheme.Spacing.md, tracking: -0.32)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.bgSecondary)
                .cornerRadius(AppTheme.Radius.xl)
                .appShadow(AppTheme.Elevation.sheet)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
                .offset(y: sheetOffset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .onAppear {
                    withAnimation(AppTheme.Motion.easeSheetIn) {
                        backdropOpacity = 1.0
                    }
                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                        sheetOffset = 0
                    }
                }
            }
        }
    }

    private func closeSheet(then completion: (() -> Void)? = nil) {
        withAnimation(AppTheme.Motion.easeSheetOut) {
            backdropOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0, blendDuration: 0)) {
            sheetOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
            completion?()
        }
    }
}

// MARK: - Landscape Helper

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
