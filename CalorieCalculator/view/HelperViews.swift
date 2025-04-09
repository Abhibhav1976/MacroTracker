import SwiftUI

// MARK: - ModernColors (Aligned with Dashboard)
enum ModernColors {
    static let background = Color(hex: "09090B")
    static let surface = Color(hex: "18181B")
    static let surfaceHover = Color(hex: "27272A")
    static let primary = Color(hex: "22C55E") // Dashboard green
    static let secondary = Color(hex: "3B82F6") // Dashboard blue
    static let accent = Color(hex: "8B5CF6") // Dashboard purple
    static let muted = Color(hex: "71717A")
    static let text = Color(hex: "FAFAFA")
    static let white = Color(hex: "FFFFFF")
    static let tertiary = Color(hex: "F97316") // Dashboard orange
    static let quaternary = Color(hex: "F97316")
    static let error = Color(hex: "EF4444")
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let destructive = Color(hex: "DC2626")
    static let glassLight = Color(hex: "FFFFFF").opacity(0.15) // Dashboard glass
    static let glassDark = Color(hex: "000000").opacity(0.3)
    static let neumorphicShadow = Color(hex: "0F0F11") // Dashboard shadow
    static let neumorphicHighlight = Color(hex: "1E1E22")
    static let glyphGlow = Color(hex: "E0E0E0") // Dashboard glyphs
    static let highlight = Color(hex: "2DD4BF") // Dashboard teal
    
    static let cosmicGlow = Color(hex: "FF3CAC")
    static let neonPulse = Color(hex: "00F7FF")
    static let voidBlack = Color(hex: "0A0A0C")
    static let prismLight = Color(hex: "FFFFFF").opacity(0.25)
    
    static let auroraPurple = Color(hex: "7B2CBF")
    static let neonLime = Color(hex: "D9ED92")
    static let eclipseBlue = Color(hex: "1A759F")
    static let radiantGold = Color(hex: "FFD60A")
    static let shimmerOverlay = Color(hex: "FFFFFF").opacity(0.05)
}

// Old Color Palette (Unchanged)
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

// MARK: - Color Extension (Assuming this exists in your project)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - SubscribeToPremiumView (Dashboard-Inspired)
struct SubscribeToPremiumView: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(ModernColors.highlight)
                .shadow(color: ModernColors.primary.opacity(0.3), radius: 4)
                .scaleEffect(animate ? 1.1 : 1.0)
            
            Text("Premium Feature")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(ModernColors.text)
                .opacity(animate ? 1 : 0)
            
            Text("This feature is available for Premium users only. Upgrade now to scan barcodes and access more features!")
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            
            Button(action: {
                // Handle the upgrade action
            }) {
                Text("Upgrade to Premium")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(ModernColors.text)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(ModernColors.glassLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ModernColors.primary.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            .scaleEffect(animate ? 1.0 : 0.95)
        }
        .padding(20)
        .background(ModernColors.glassDark)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: ModernColors.neumorphicShadow.opacity(0.3), radius: 6)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - PopupView (Glassmorphic Dashboard Style)
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
            ModernColors.background.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                        onClose?()
                    }
                }
            
            content
                .padding(20)
                .background(ModernColors.glassDark)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: ModernColors.neumorphicShadow.opacity(0.3), radius: 6)
                .frame(maxWidth: 340)
        }
        .transition(.opacity)
    }
}

// MARK: - StyledTextField (Dashboard-Inspired Input)
struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    @State private var isFocused = false
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(10)
            .background(ModernColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ModernColors.highlight.opacity(isFocused ? 0.7 : 0.3), lineWidth: 1)
            )
            .foregroundStyle(ModernColors.text)
            .font(.custom("Azeret Mono", size: 14))
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .onTapGesture { isFocused = true }
            .onSubmit { isFocused = false }
    }
}

// MARK: - SuccessView (Dashboard-Styled Success)
struct SuccessView: View {
    let message: String
    @Binding var isPresented: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ModernColors.background.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(ModernColors.primary)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .shadow(color: ModernColors.primary.opacity(0.3), radius: 4)
                
                Text("Success!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(ModernColors.text)
                    .opacity(animate ? 1 : 0)
                
                Text(message)
                    .font(.custom("Azeret Mono", size: 14))
                    .foregroundColor(ModernColors.muted)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
            }
            .padding(20)
            .background(ModernColors.glassDark)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ModernColors.primary.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: ModernColors.neumorphicShadow.opacity(0.3), radius: 6)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - ErrorView (Dashboard-Styled Error)
struct ErrorView: View {
    let message: String
    @Binding var isPresented: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ModernColors.background.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(ModernColors.error)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .shadow(color: ModernColors.error.opacity(0.3), radius: 4)
                
                Text("Error!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(ModernColors.text)
                    .opacity(animate ? 1 : 0)
                
                Text(message)
                    .font(.custom("Azeret Mono", size: 14))
                    .foregroundColor(ModernColors.muted)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Text("Retry")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(ModernColors.text)
                        .padding(.vertical, 8)
                        .frame(width: 80)
                        .background(ModernColors.glassLight)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ModernColors.error.opacity(0.5), lineWidth: 1)
                        )
                }
                .opacity(animate ? 1 : 0)
            }
            .padding(20)
            .background(ModernColors.glassDark)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ModernColors.error.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: ModernColors.neumorphicShadow.opacity(0.3), radius: 6)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - StatItem (Unchanged)
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

// MARK: - DishCard (Unchanged)
struct DishCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(ModernColors.muted)
                .frame(height: 120)
                .cornerRadius(12)
            
            Text("Dish Name")
                .font(.headline)
                .foregroundColor(ModernColors.white)
            
            Text("500 calories")
                .font(.subheadline)
                .foregroundColor(ModernColors.muted)
        }
        .padding()
        .background(ModernColors.surface)
        .cornerRadius(16)
    }
}

// MARK: - GridLayout (Unchanged)
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

// MARK: - ScaleButtonStyle (Unchanged)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - MacroInputView (Dashboard-Inspired Redesign)
struct MacroInputView: View {
    @Binding var isPresented: Bool
    @State private var carbs: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var calories: Int = 0
    @State private var selectedMealType: String = ""
    @State private var showSuccess: Bool = false
    @State private var animate = false
    
    @EnvironmentObject var macrosModel: Macros
    let userId: Int
    
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Macros logged successfully!",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Quick Add Macros", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text("Quick Add Macros")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(ModernColors.text)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 10)
                    
                    HStack(spacing: 10) {
                        ForEach(mealTypes, id: \.self) { type in
                            MealTypeIcon(
                                type: type,
                                isSelected: selectedMealType == type,
                                action: { selectedMealType = type }
                            )
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 15)
                            .animation(
                                .easeInOut(duration: 0.4).delay(Double(mealTypes.firstIndex(of: type) ?? 0) * 0.1),
                                value: animate
                            )
                        }
                    }
                    
                    ZStack {
                        Circle()
                            .fill(ModernColors.glassLight.opacity(0.7))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(ModernColors.primary.opacity(0.5), lineWidth: 1)
                            )
                        
                        VStack(spacing: 2) {
                            Text("\(calories)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(ModernColors.highlight)
                            Text("kcal")
                                .font(.custom("Azeret Mono", size: 12))
                                .foregroundColor(ModernColors.muted)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.9)
                    .onChange(of: carbs) { _ in calculateCalories() }
                    .onChange(of: protein) { _ in calculateCalories() }
                    .onChange(of: fat) { _ in calculateCalories() }
                    
                    HStack(spacing: 12) {
                        StyledTextField(placeholder: "Carbs", text: $carbs, keyboardType: .numberPad)
                        StyledTextField(placeholder: "Protein", text: $protein, keyboardType: .numberPad)
                        StyledTextField(placeholder: "Fat", text: $fat, keyboardType: .numberPad)
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(x: animate ? 0 : 20)
                    
                    Button(action: submitMacros) {
                        Text("Save")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(ModernColors.text)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(ModernColors.primary.opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ModernColors.neumorphicHighlight.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .disabled(carbs.isEmpty || protein.isEmpty || fat.isEmpty || selectedMealType.isEmpty)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.95)
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    animate = true
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
                withAnimation(.easeOut(duration: 0.3)) {
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

// MARK: - MealTypeIcon (Dashboard Glass Style)
struct MealTypeIcon: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    
    private var iconName: String {
        switch type {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "sun.max.fill"
        case "Dinner": return "moon.stars.fill"
        case "Snacks": return "leaf.fill"
        default: return ""
        }
    }
    
    private var typeColor: Color {
        switch type {
        case "Breakfast": return ModernColors.primary
        case "Lunch": return ModernColors.secondary
        case "Dinner": return ModernColors.accent
        case "Snacks": return ModernColors.tertiary
        default: return ModernColors.muted
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? typeColor.opacity(0.7) : ModernColors.glassLight)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(ModernColors.neumorphicHighlight.opacity(isSelected ? 0.7 : 0.3), lineWidth: 1)
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(ModernColors.text)
            }
        }
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
                .placeholder(when: text.isEmpty, content: {
                    Text(placeholder)
                        .foregroundColor(ModernColors.muted)
                })
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
