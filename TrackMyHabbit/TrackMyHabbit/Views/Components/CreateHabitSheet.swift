import SwiftUI
import SwiftData

struct CreateHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Optional: when non-nil, the sheet is in "edit" mode
    var editingHabit: Habit? = nil
    
    private var isEditMode: Bool { editingHabit != nil }
    
    // Form state
    @State private var habitName: String = ""
    @FocusState private var isInputFocused: Bool
    
    // Frequency state
    @State private var selectedFrequency = FrequencyOption.options.first ?? FrequencyOption(id: "everyday", label: "Everyday")
    @State private var showFrequencySheet = false
    
    // Sub-selection states
    @State private var selectedDayOfWeek: DayOfWeek = .wednesday
    @State private var selectedDayOfMonth: Int = 23
    @State private var selectedMonth: MonthOfYear = .march
    
    // Sub-selection sheet visibility
    @State private var showDayOfWeekSheet = false
    @State private var showDayOfMonthSheet = false
    @State private var showMonthSheet = false
    
    // Delete confirmation
    @State private var showDeleteAlert = false

    // Save/delete error handling
    @State private var showPersistenceErrorAlert = false
    @State private var persistenceErrorMessage = ""
    
    // Animation scale for frequency trigger button
    @State private var frequencyScale: CGFloat = 1.0
    
    let suggestions = [
        "Go to the gym",
        "Water plants",
        "Run everyday",
        "Sleep on time",
        "Eat a balanced diet",
        "Stay hydrated"
    ]
    
    var body: some View {
        ZStack {
            AppTheme.Colors.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Navigation Header
                HStack {
                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(AppTheme.Colors.bgPrimary)
                                    .overlay(Circle().stroke(AppTheme.Colors.bgPrimary, lineWidth: 1))
                                    .shadow(color: Color(hex: "#5E5E72").opacity(0.4), radius: 56, x: 0, y: 4.416)
                            )
                    }
                    
                    Spacer()
                    
                    // Action buttons container (Delete + Confirm)
                    let hasName = !habitName.trimmingCharacters(in: .whitespaces).isEmpty
                    
                    HStack(spacing: 12) {
                        // Delete button — only visible in edit mode
                        if isEditMode {
                            Button(action: { showDeleteAlert = true }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(hex: "#E53935"))
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(AppTheme.Colors.bgPrimary)
                                            .shadow(color: Color(hex: "#5E5E72").opacity(0.4), radius: 56, x: 0, y: 4.416)
                                    )
                            }
                        }
                        
                        // Confirm button
                        Button(action: saveHabit) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(hasName ? AppTheme.Colors.systemBlue : AppTheme.Colors.textDisabled)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(AppTheme.Colors.bgPrimary)
                                        .shadow(color: Color(hex: "#5E5E72").opacity(0.4), radius: 56, x: 0, y: 4.416)
                                )
                        }
                        .disabled(!hasName)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
                
                // MARK: Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // Input Section
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("I want to")
                                .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            TextField("", text: $habitName, prompt: Text("Enter your habit").foregroundColor(AppTheme.Colors.textDisabled))
                                .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .tint(AppTheme.Colors.primary) // cursor color
                                .focused($isInputFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                                        saveHabit()
                                    }
                                }
                            
                            if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                                frequencyInlineView
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 32)
                        
                        Divider()
                            .background(AppTheme.Neutral._300)
                            .padding(.bottom, AppTheme.Spacing.xl)
                        
                        // Suggestions Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Trying to build a habit? Start small")
                                .customFont(.semibold, size: 16, tracking: -0.32)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .padding(.bottom, AppTheme.Spacing.xs)
                            
                            Text("Here are a few suggestions to start off!")
                                .customFont(.medium, size: 16, tracking: -0.08)
                                .foregroundColor(AppTheme.Colors.textDisabled)
                                .padding(.bottom, AppTheme.Spacing.xl)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        habitName = suggestion
                                        isInputFocused = true
                                    }) {
                                        Text(suggestion)
                                            .customFont(.medium, size: 14, tracking: -0.07)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                    .fill(AppTheme.Colors.bgPrimary)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                            .stroke(AppTheme.Colors.bgTertiary, lineWidth: 1)
                                                    )
                                                    .shadow(color: Color(hex: "#5E5E72").opacity(0.2), radius: 56, x: 0, y: 4.416)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Bottom Padding for scroll
                        Spacer().frame(height: anySheetVisible ? 380 : AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
            
            // MARK: - Bottom Sheet Overlays
            
            // Main frequency selector
            if showFrequencySheet {
                FrequencyBottomSheet(
                    isPresented: $showFrequencySheet,
                    selectedOption: $selectedFrequency
                )
            }
            
            // Day of week picker (for "every week")
            if showDayOfWeekSheet {
                DayOfWeekBottomSheet(
                    isPresented: $showDayOfWeekSheet,
                    selectedDay: $selectedDayOfWeek
                )
            }
            
            // Day of month picker (for "every month" and "every year")
            if showDayOfMonthSheet {
                DayOfMonthBottomSheet(
                    isPresented: $showDayOfMonthSheet,
                    selectedDay: $selectedDayOfMonth
                )
            }
            
            // Month picker (for "every year")
            if showMonthSheet {
                MonthPickerBottomSheet(
                    isPresented: $showMonthSheet,
                    selectedMonth: $selectedMonth
                )
            }
        }
        .onAppear {
            // Pre-populate form when editing
            if let habit = editingHabit {
                habitName = habit.name
                loadFrequencyFrom(habit.frequency)
            }
            isInputFocused = true
        }
        .alert("Delete Habit", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteHabit() }
        } message: {
            Text("Are you sure you want to delete \"\(editingHabit?.name ?? "")\"? This action cannot be undone.")
        }
        .alert("Couldn’t Save", isPresented: $showPersistenceErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(persistenceErrorMessage)
        }
    }
    
    // MARK: - Frequency Inline View
    
    /// Builds the inline text below the habit name based on the selected frequency.
    /// Uses attributed-style layout with tappable underlined text for sub-selections.
    @ViewBuilder
    private var frequencyInlineView: some View {
        let freq = selectedFrequency
        let scaleAnimation: Animation? = reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6)
        
        switch freq.id {
        case "everyday", "every_weekday", "every_weekend":
            // Simple: just "everyday." / "every weekday." / "every weekend."
            Button(action: presentFrequencySheet) {
                Text(freq.simpleInlineLabel)
                    .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .underline()
            }
            .scaleEffect(frequencyScale)
            .animation(scaleAnimation, value: frequencyScale)
            
        case "every_week":
            // "every week, on  wednesday" — single line
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: presentFrequencySheet) {
                        Text("every week,")
                            .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .underline()
                    }
                    Text(" on")
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .scaleEffect(frequencyScale)
                .animation(scaleAnimation, value: frequencyScale)
                
                Button(action: presentDayOfWeekSheet) {
                    Text(selectedDayOfWeek.name.lowercased())
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .underline()
                }
            }
            
        case "every_month":
            // "every month, on the  23rd" — single line
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: presentFrequencySheet) {
                        Text("every month,")
                            .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .underline()
                    }
                    Text(" on the")
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .scaleEffect(frequencyScale)
                .animation(scaleAnimation, value: frequencyScale)
                
                Button(action: presentDayOfMonthSheet) {
                    Text(ordinalSuffix(for: selectedDayOfMonth))
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .underline()
                }
            }
            
        case "every_year":
            // "every year, on  March  23rd" — single line
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: presentFrequencySheet) {
                        Text("every year,")
                            .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .underline()
                    }
                    Text(" on")
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .scaleEffect(frequencyScale)
                .animation(scaleAnimation, value: frequencyScale)
                
                Button(action: presentMonthSheet) {
                    Text(selectedMonth.name)
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .underline()
                }
                
                Button(action: presentDayOfMonthSheet) {
                    Text(ordinalSuffix(for: selectedDayOfMonth))
                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .underline()
                }
            }
            
        default:
            Button(action: presentFrequencySheet) {
                Text(freq.simpleInlineLabel)
                    .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .underline()
            }
            .scaleEffect(frequencyScale)
            .animation(scaleAnimation, value: frequencyScale)
        }
    }
    
    // MARK: - Computed Properties
    
    private var anySheetVisible: Bool {
        showFrequencySheet || showDayOfWeekSheet || showDayOfMonthSheet || showMonthSheet
    }
    
    /// Builds the full frequency string for saving
    private var frequencyString: String {
        switch selectedFrequency.id {
        case "everyday": return "everyday"
        case "every_week": return "every_week:\(selectedDayOfWeek.rawValue)"
        case "every_weekday": return "every_weekday"
        case "every_weekend": return "every_weekend"
        case "every_month": return "every_month:\(selectedDayOfMonth)"
        case "every_year": return "every_year:\(selectedMonth.rawValue):\(selectedDayOfMonth)"
        default: return selectedFrequency.label
        }
    }
    
    // MARK: - Actions
    
    private func presentFrequencySheet() {
        isInputFocused = false

        if reduceMotion {
            frequencyScale = 1.0
            showFrequencySheet = true
            return
        }

        withAnimation(.easeOut(duration: 0.1)) {
            frequencyScale = 0.96
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            frequencyScale = 1.0
            showFrequencySheet = true
        }
    }
    
    private func presentDayOfWeekSheet() {
        isInputFocused = false
        showDayOfWeekSheet = true
    }
    
    private func presentDayOfMonthSheet() {
        isInputFocused = false
        showDayOfMonthSheet = true
    }
    
    private func presentMonthSheet() {
        isInputFocused = false
        showMonthSheet = true
    }
    
    private func saveHabit() {
        let cleanName = habitName.trimmingCharacters(in: .whitespaces)
        guard !cleanName.isEmpty else { return }
        
        if let existing = editingHabit {
            // Update existing habit
            existing.name = cleanName
            existing.frequency = frequencyString
        } else {
            // Create new habit
            let newHabit = Habit(name: cleanName, frequency: frequencyString)
            modelContext.insert(newHabit)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            persistenceErrorMessage = error.localizedDescription
            showPersistenceErrorAlert = true
        }
    }
    
    private func deleteHabit() {
        guard let habit = editingHabit else { return }
        modelContext.delete(habit)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            persistenceErrorMessage = error.localizedDescription
            showPersistenceErrorAlert = true
        }
    }
    
    /// Parses a stored frequency string and restores the form state
    private func loadFrequencyFrom(_ freq: String) {
        let parts = freq.split(separator: ":").map(String.init)
        let baseId = parts.first ?? freq
        
        if let matched = FrequencyOption.options.first(where: { $0.id == baseId }) {
            selectedFrequency = matched
        }
        
        switch baseId {
        case "every_week":
            if parts.count > 1, let raw = Int(parts[1]),
               let day = DayOfWeek(rawValue: raw) {
                selectedDayOfWeek = day
            }
        case "every_month":
            if parts.count > 1, let day = Int(parts[1]) {
                selectedDayOfMonth = day
            }
        case "every_year":
            if parts.count > 2,
               let monthRaw = Int(parts[1]),
               let month = MonthOfYear(rawValue: monthRaw),
               let day = Int(parts[2]) {
                selectedMonth = month
                selectedDayOfMonth = day
            }
        default:
            break
        }
    }
}

// Preview Provider
#Preview {
    CreateHabitSheet()
        .modelContainer(for: Habit.self, inMemory: true)
}
