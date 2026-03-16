import SwiftUI
import SwiftData

struct CreateHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state
    @State private var habitName: String = ""
    @FocusState private var isInputFocused: Bool
    
    // Frequency state
    @State private var selectedFrequency = FrequencyOption.options.first!
    @State private var showFrequencySheet = false
    
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
                            .background(AppTheme.Colors.bgPrimary)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.bgTertiary, lineWidth: 1))
                            .shadow(color: Color(hex: "#5E5E72").opacity(0.2), radius: 56, x: 0, y: 4.41)
                    }
                    
                    Spacer()
                    
                    // Confirm button
                    let hasName = !habitName.trimmingCharacters(in: .whitespaces).isEmpty
                    
                    Button(action: saveHabit) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(hasName ? AppTheme.Colors.systemBlue : AppTheme.Colors.textDisabled)
                            .frame(width: 48, height: 48)
                            .background(AppTheme.Colors.bgPrimary)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.bgTertiary, lineWidth: 1))
                            .shadow(color: Color(hex: "#5E5E72").opacity(hasName ? 0.2 : 0.1), radius: 56, x: 0, y: 4.41)
                    }
                    .disabled(!hasName)
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
                                Button(action: presentFrequencySheet) {
                                    Text(selectedFrequency.inlineLabel)
                                        .customFont(.semibold, size: 24, lineHeight: 29, tracking: -0.48)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                        .underline()
                                }
                                .scaleEffect(frequencyScale)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: frequencyScale)
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
                                            .background(AppTheme.Colors.bgPrimary)
                                            .cornerRadius(24)
                                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.Colors.bgTertiary, lineWidth: 1))
                                            .shadow(color: AppTheme.Neutral._700.opacity(0.2), radius: 56, x: 0, y: 4)
                                    }
                                }
                            }
                        }
                        
                        // Bottom Padding for scroll
                        Spacer().frame(height: showFrequencySheet ? 380 : AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
            
            // Custom Frequency Bottom SheetOverlay
            if showFrequencySheet {
                FrequencyBottomSheet(
                    isPresented: $showFrequencySheet,
                    selectedOption: $selectedFrequency
                )
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private func presentFrequencySheet() {
        // Dismiss keyboard
        isInputFocused = false
        
        // Button press animation
        withAnimation(.easeOut(duration: 0.1)) {
            frequencyScale = 0.96
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            frequencyScale = 1.0
            showFrequencySheet = true
        }
    }
    
    private func saveHabit() {
        let cleanName = habitName.trimmingCharacters(in: .whitespaces)
        guard !cleanName.isEmpty else { return }
        
        // Create SwiftData model object
        let newHabit = Habit(name: cleanName, frequency: selectedFrequency.label)
        modelContext.insert(newHabit)
        
        // Save Context (SwiftData autosaves, but we force it here to be safe before dismissing)
        try? modelContext.save()
        
        dismiss()
    }
}

// Preview Provider
#Preview {
    CreateHabitSheet()
        .modelContainer(for: Habit.self, inMemory: true)
}
