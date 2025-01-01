import SwiftUI

// New Color Palette
enum ModernColors {
    static let background = Color(hex: "09090B")
    static let surface = Color(hex: "18181B")
    static let surfaceHover = Color(hex: "27272A")
    static let primary = Color(hex: "22C55E")
    static let secondary = Color(hex: "3B82F6")
    static let accent = Color(hex: "8B5CF6")
    static let muted = Color(hex: "71717A")
    static let text = Color(hex: "FAFAFA")
    static let white = Color(hex: "FFFFFF")
    static let tertiary = Color(hex: "F97316")
    static let quaternary = Color(hex: "F97316")

    // Adding error and success states
    static let error = Color(hex: "EF4444")
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let destructive = Color(hex: "DC2626")
}

// Old Color Palette
struct ColorPalette {
    static let background = Color(hex: "121212")
    static let cardBackground = Color(hex: "1E1E1E")
    static let primaryButton = Color(hex: "4CAF50")
    static let secondaryButton = Color(hex: "03A9F4")
    static let subtext = Color(hex: "B0BEC5")
    static let success = Color(hex: "8BC34A")
    static let error = Color(hex: "F44336")
    static let inactive = Color(hex: "757575")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255.0
        let g = Double((int & 0x00FF00) >> 8) / 255.0
        let b = Double(int & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// Needs to be updated
struct PopupView<Content: View>: View {
    let title: String
    let content: Content
    @Binding var isPresented: Bool
    var onClose: (() -> Void)? = nil
    
    init(title: String, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPresented = false
                        onClose?()
                    }
                }
            
            VStack(spacing: 0) {
                content
                    .padding()
                    .background(ModernColors.background)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPresented = false
                        onClose?()
                    }
                }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ModernColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ModernColors.surface)
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    @State private var isFocused: Bool = false
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding()
            .background(ModernColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? ModernColors.primary : ModernColors.muted.opacity(0.5), lineWidth: 1)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .foregroundColor(ModernColors.text)
            .onTapGesture {
                isFocused = true
            }
            .onSubmit {
                isFocused = false
            }
    }
}

struct SuccessView: View {
    let message: String
    @Binding var isPresented: Bool
    @State private var animate: Bool = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ModernColors.background,
                ModernColors.surface,
                ModernColors.background
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(ModernColors.primary)
                .scaleEffect(animate ? 1.1 : 0.5)
                .opacity(animate ? 1 : 0)
            
            Text("Congratulation")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ModernColors.text)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
        }
        .padding(.vertical, 40)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    @Binding var isPresented: Bool
    @State private var animate: Bool = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ModernColors.background,
                ModernColors.surface,
                ModernColors.background
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(ModernColors.error)
                .scaleEffect(animate ? 1.1 : 0.5)
                .opacity(animate ? 1 : 0)
            
            Text("Error")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ModernColors.text)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPresented = false
                }
            }) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColors.text)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(ModernColors.primary)
                    .cornerRadius(8)
            }
            .buttonStyle(ScaleButtonStyle())
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)
        }
        .padding(.vertical, 40)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
}
// Original components kept from the previous version
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(ModernColors.accent)
                .rotationEffect(.degrees(isHovered ? 360 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isHovered)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ModernColors.muted)
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ModernColors.text)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ModernColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ModernColors.accent.opacity(0.5),
                                    ModernColors.primary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isHovered ? 2 : 0
                        )
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}

struct DishCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(ColorPalette.inactive)
                .frame(height: 120)
                .cornerRadius(12)
            
            Text("Dish Name")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("500 calories")
                .font(.subheadline)
                .foregroundColor(ColorPalette.subtext)
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(16)
    }
}
 
struct GridLayout: Layout {
    var columns: Int
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = (subviews.count + columns - 1) / columns
        let width = proposal.width ?? 0
        let itemWidth = (width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        let height = (itemWidth + spacing) * CGFloat(rows) - spacing
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let itemWidth = (bounds.width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        
        for (index, subview) in subviews.enumerated() {
            let row = index / columns
            let column = index % columns
            let x = bounds.minX + (itemWidth + spacing) * CGFloat(column)
            let y = bounds.minY + ((itemWidth + spacing) * CGFloat(row)) * 0.8
            let point = CGPoint(x: x, y: y)
            subview.place(at: point, proposal: ProposedViewSize(width: itemWidth, height: itemWidth))
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct MealTypeIcon: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    
    private var iconName: String {
        switch type {
        case "Breakfast": return "sun.and.horizon.fill"
        case "Lunch": return "sun.max.fill"
        case "Dinner": return "moon.stars.fill"
        case "Snacks": return "bag.fill"
        default: return ""
        }
    }
    
    private var gradientColors: [Color] {
        switch type {
        case "Breakfast": return [Color(hex: "FF6B6B"), Color(hex: "FFA06B")]
        case "Lunch": return [Color(hex: "4FACFE"), Color(hex: "00F2FE")]
        case "Dinner": return [Color(hex: "8B5CF6"), Color(hex: "6366F1")]
        case "Snacks": return [Color(hex: "22C55E"), Color(hex: "16A34A")]
        default: return [ModernColors.muted]
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text(type)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .white : .clear, lineWidth: 3)
            )
            .cornerRadius(16)
            .shadow(
                color: isSelected ? gradientColors[0].opacity(0.5) : Color.black.opacity(0.1),
                radius: isSelected ? 10 : 5,
                x: 0,
                y: isSelected ? 5 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}

// New Enhanced Input View
struct MacroInputView: View {
    @Binding var isPresented: Bool
    @State private var carbs: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var calories: Int = 0
    @State private var selectedMealType: String = ""
    @State private var showSuccess: Bool = false
    @State private var appearAnimation: Bool = false
    
    @EnvironmentObject var macrosModel: Macros
    let userId: Int
    
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Your macros have been added successfully",
                isPresented: $isPresented
            )
        } else {
            ModernPopupContainer(isPresented: $isPresented) {
                AnyView(
                    ScrollView {
                        VStack(spacing: 32) {
                            // Title with animation
                            Text("Add Your Meal")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(ModernColors.text)
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 20)
                            
                            // Meal type grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(mealTypes, id: \.self) { type in
                                    MealTypeIcon(
                                        type: type,
                                        isSelected: selectedMealType == type,
                                        action: { selectedMealType = type }
                                    )
                                    .offset(y: appearAnimation ? 0 : 50)
                                    .opacity(appearAnimation ? 1 : 0)
                                }
                            }
                            .padding(.horizontal, 8)
                            
                            // Macro inputs
                            VStack(spacing: 20) {
                                ModernTextField(
                                    placeholder: "🥖 Carbs (g)",
                                    text: $carbs,
                                    keyboardType: .numberPad
                                )
                                .offset(y: appearAnimation ? 0 : 30)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                ModernTextField(
                                    placeholder: "🥩 Protein (g)",
                                    text: $protein,
                                    keyboardType: .numberPad
                                )
                                .offset(y: appearAnimation ? 0 : 30)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                ModernTextField(
                                    placeholder: "🥑 Fat (g)",
                                    text: $fat,
                                    keyboardType: .numberPad
                                )
                                .offset(y: appearAnimation ? 0 : 30)
                                .opacity(appearAnimation ? 1 : 0)
                            }
                            
                            // Calories display
                            VStack(spacing: 4) {
                                Text("Total Calories")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(ModernColors.muted)
                                
                                Text("\(calories) kcal")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(ModernColors.text)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(ModernColors.surface)
                            .cornerRadius(16)
                            .offset(y: appearAnimation ? 0 : 30)
                            .opacity(appearAnimation ? 1 : 0)
                            .onChange(of: carbs) { _ in calculateCalories() }
                            .onChange(of: protein) { _ in calculateCalories() }
                            .onChange(of: fat) { _ in calculateCalories() }
                            
                            // Save button with gradient and animation
                            Button(action: submitMacros) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Meal")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [ModernColors.primary, ModernColors.primary.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: ModernColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(carbs.isEmpty || protein.isEmpty || fat.isEmpty || selectedMealType.isEmpty)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 30)                        }
                        .padding(24)
                    }
                )
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
            }
        }
    }
    
    private func calculateCalories() {
        let carbsCal = (Int(carbs) ?? 0) * 4
        let proteinCal = (Int(protein) ?? 0) * 4
        let fatCal = (Int(fat) ?? 0) * 9
        calories = carbsCal + proteinCal + fatCal
    }
    
    private func submitMacros() {
        guard let carbsInt = Int(carbs),
              let proteinInt = Int(protein),
              let fatInt = Int(fat),
              !selectedMealType.isEmpty else {
            return
        }
        
        calculateCalories()
        
        macrosModel.addMacros(
            userId: userId,
            entryDate: currentDate,
            mealType: selectedMealType,
            calories: calories,
            carbs: carbsInt,
            protein: proteinInt,
            fat: fatInt
        ) { result in
            switch result {
            case .success:
                withAnimation {
                    showSuccess = true
                }
            case .failure(let error):
                print("Error adding macros: \(error.localizedDescription)")
            }
        }
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}


struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    let content: Content
    @Namespace private var animation
    
    init(
        title: String,
        icon: String,
        isSelected: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onTap) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? ModernColors.primary : ModernColors.muted)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ModernColors.text)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(ModernColors.muted)
                        .rotationEffect(.degrees(isSelected ? 90 : 0))
                }
            }
            
            if isSelected {
                VStack(spacing: 16) {
                    content
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .background(ModernColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String = ""
    var showArrow: Bool = false
    var isToggle: Bool = false
    var toggleValue: Binding<Bool>?
    var action: (() -> Void)?
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = true
            }
            action?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(ModernColors.muted)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(ModernColors.text)
                
                Spacer()
                
                if isToggle, let binding = toggleValue {
                    Toggle("", isOn: binding)
                        .labelsHidden()
                        .tint(ModernColors.primary)
                } else {
                    if !value.isEmpty {
                        Text(value)
                            .font(.system(size: 14))
                            .foregroundColor(ModernColors.muted)
                    }
                    
                    if showArrow {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(ModernColors.muted)
                    }
                }
            }
        }
        .padding(12)
        .background(isPressed ? ModernColors.surfaceHover : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}


struct UpdateWeightView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var updateModel: UpdateModel
    @State private var weight: String = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @Binding var isPresented: Bool
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Your weight has been updated successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Update Weight", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text("Update Weight")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    StyledTextField(
                        placeholder: "Current Weight (kg)",
                        text: $weight,
                        keyboardType: .decimalPad
                    )
                    .disabled(isLoading)
                    
                    Button(action: updateWeight) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ColorPalette.primaryButton)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading || weight.isEmpty)
                }
            }
        }
    }
    
    private func updateWeight() {
        guard let weightValue = Double(weight) else {
            return
        }
        
        isLoading = true
        updateModel.updateProfile(
            age: nil,
            currentWeight: weightValue,
            targetWeight: nil,
            requiredCalories: nil,
            height: nil,
            activityLevel: nil,
            gender: nil,
            goalType: nil,
            profilePicture: nil
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                print("Update failed: \(error)")
            }
        }
    }
}
struct UpdateTargetWeightView: View {
    @ObservedObject var updateModel: UpdateModel
    @State private var targetWeight: String = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @Binding var isPresented: Bool
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Your target weight has been updated successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Update Target Weight", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text("Update Target Weight")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    StyledTextField(
                        placeholder: "Target Weight (kg)",
                        text: $targetWeight,
                        keyboardType: .decimalPad
                    )
                    .disabled(isLoading)
                    
                    Button(action: updateTargetWeight) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ColorPalette.primaryButton)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading || targetWeight.isEmpty)
                }
            }
        }
    }
    
    private func updateTargetWeight() {
        guard let weightValue = Double(targetWeight) else {
            return
        }
        
        isLoading = true
        updateModel.updateProfile(
            age: nil,
            currentWeight: nil,
            targetWeight: weightValue,
            requiredCalories: nil,
            height: nil,
            activityLevel: nil,
            gender: nil,
            goalType: nil,
            profilePicture: nil
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                print("Update failed: \(error)")
            }
        }
    }
}

struct UpdateAgeView: View {
    @ObservedObject var updateModel: UpdateModel
    @State private var age: String = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @Binding var isPresented: Bool
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Your age has been updated successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Update Age", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text("Update Age")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    StyledTextField(
                        placeholder: "Age",
                        text: $age,
                        keyboardType: .numberPad
                    )
                    .disabled(isLoading)
                    
                    Button(action: updateAge) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ColorPalette.primaryButton)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading || age.isEmpty)
                }
            }
        }
    }
    
    private func updateAge() {
        guard let ageValue = Int(age) else {
            return
        }
        
        isLoading = true
        updateModel.updateProfile(
            age: ageValue,
            currentWeight: nil,
            targetWeight: nil,
            requiredCalories: nil,
            height: nil,
            activityLevel: nil,
            gender: nil,
            goalType: nil,
            profilePicture: nil
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                print("Update failed: \(error)")
            }
        }
    }
}

struct UpdateGoalsView: View {
    @ObservedObject var updateModel: UpdateModel
    @State private var calories: String = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @Binding var isPresented: Bool
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Your daily calorie goal has been updated successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Update Goals", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text("Update Daily Calories")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    StyledTextField(
                        placeholder: "Daily Calories (kcal)",
                        text: $calories,
                        keyboardType: .numberPad
                    )
                    .disabled(isLoading)
                    
                    Button(action: updateGoals) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ColorPalette.primaryButton)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading || calories.isEmpty)
                }
            }
        }
    }
    
    private func updateGoals() {
        guard let caloriesValue = Int(calories) else {
            return
        }
        
        isLoading = true
        updateModel.updateProfile(
            age: nil,
            currentWeight: nil,
            targetWeight: nil,
            requiredCalories: caloriesValue,
            height: nil,
            activityLevel: nil,
            gender: nil,
            goalType: nil,
            profilePicture: nil
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                print("Update failed: \(error)")
            }
        }
    }
}
// Modern Button Style
struct ModernButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isDisabled {
                        ModernColors.muted
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [ModernColors.primary, ModernColors.primary.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: ModernColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled || isLoading)
    }
}

// Modern styled text field
struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(ModernColors.muted)
                }
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .foregroundColor(ModernColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(ModernColors.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ModernColors.muted.opacity(0.5), lineWidth: 1)
                )
                .disabled(isDisabled)
        }
    }
}

// View modifier for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Modern popup container
struct ModernPopupContainer: View {
    @Binding var isPresented: Bool
    let content: () -> AnyView
    
    var body: some View {
        ZStack {
            ModernColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                AnyView(content())
            }
            .padding(24)
            .background(ModernColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 16)
            .padding(.horizontal, 24)
        }
    }
}
