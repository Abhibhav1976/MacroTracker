import SwiftUI

struct FoodInputView: View {
    @Binding var isPresented: Bool
    @State private var foodName: String = ""
    @State private var carbs: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var showingFeedback = false
    @State private var isSuccess = false
    @State private var feedbackMessage = ""
    @State private var savedBarcode: String = ""
    
    let barcode: String
    let userId: Int
    
    // Computed property to calculate calories dynamically
    private var calculatedCalories: Int {
        let carbsValue = Double(carbs) ?? 0.0
        let proteinValue = Double(protein) ?? 0.0
        let fatValue = Double(fat) ?? 0.0
        return Int((carbsValue * 4) + (proteinValue * 4) + (fatValue * 9))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ModernColors.voidBlack
                    .ignoresSafeArea()
                
                if showingFeedback {
                    if isSuccess {
                        SuccessOverlay(
                            message: feedbackMessage,
                            isPresented: $showingFeedback
                        )
                    } else {
                        ErrorOverlay(
                            message: feedbackMessage,
                            isPresented: $showingFeedback
                        )
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("Add Food Details")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(ModernColors.text)
                                .shadow(color: ModernColors.neonPulse.opacity(0.3), radius: 4)
                            
                            VStack(spacing: 20) {
                                NeumorphicTextField(placeholder: "Food Name", text: $foodName, keyboardType: .default)
                                
                                HStack {
                                    Text("Calories:")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ModernColors.muted)
                                    Spacer()
                                    Text("\(calculatedCalories)")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(ModernColors.neonPulse)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            Capsule()
                                                .fill(ModernColors.surface)
                                                .shadow(color: ModernColors.neonPulse.opacity(0.4), radius: 6)
                                        )
                                }
                                
                                NeumorphicTextField(placeholder: "Carbs (g)", text: $carbs, keyboardType: .decimalPad)
                                NeumorphicTextField(placeholder: "Protein (g)", text: $protein, keyboardType: .decimalPad)
                                NeumorphicTextField(placeholder: "Fat (g)", text: $fat, keyboardType: .decimalPad)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ModernColors.surface)
                                    .shadow(color: ModernColors.neumorphicShadow, radius: 10, x: 5, y: 5)
                                    .shadow(color: ModernColors.neumorphicHighlight, radius: 10, x: -5, y: -5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(ModernColors.prismLight, lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            
                            Button(action: saveFoodInfo) {
                                Text("Save Food")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(ModernColors.text)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [ModernColors.neonPulse, ModernColors.cosmicGlow]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: ModernColors.neonPulse.opacity(0.6), radius: 8)
                                    .scaleEffect(showingFeedback ? 1.0 : 1.02)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true),
                                        value: showingFeedback
                                    )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 40)
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColors.neonPulse)
                    .padding(8)
                    .background(ModernColors.glassDark)
                    .cornerRadius(8)
            })
            .onAppear {
                if savedBarcode.isEmpty {
                    savedBarcode = barcode
                    print("Copied barcode to savedBarcode: \(savedBarcode)")
                }
            }
        }
    }
    
    private func saveFoodInfo() {
        guard !foodName.isEmpty,
              let carbsDouble = Double(carbs),
              let proteinDouble = Double(protein),
              let fatDouble = Double(fat) else {
            feedbackMessage = "Please enter valid numbers for all fields"
            isSuccess = false
            showingFeedback = true
            return
        }
        
        let caloriesInt = calculatedCalories
        
        fetchFoodInfo(
            barcode: savedBarcode,
            foodName: foodName,
            calories: caloriesInt,
            carbs: carbsDouble,
            protein: proteinDouble,
            fat: fatDouble,
            userId: userId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let scannedFood):
                    feedbackMessage = scannedFood.message
                    isSuccess = true
                    showingFeedback = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isPresented = false
                    }
                case .failure(let error):
                    feedbackMessage = error.localizedDescription
                    isSuccess = false
                    showingFeedback = true
                }
            }
        }
    }
}

// New Helper Views (Unchanged from previous)
struct NeumorphicTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    @State private var isFocused: Bool = false
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(ModernColors.text)
            .placeholder(when: text.isEmpty, content: {
                Text(placeholder)
                    .foregroundColor(ModernColors.muted)
                    .font(.system(size: 16))
            })
            .keyboardType(keyboardType)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ModernColors.surface)
                    .shadow(color: ModernColors.neumorphicShadow, radius: 6, x: 4, y: 4)
                    .shadow(color: ModernColors.neumorphicHighlight, radius: 6, x: -4, y: -4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? ModernColors.neonPulse : ModernColors.prismLight, lineWidth: 1)
            )
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .onTapGesture { isFocused = true }
            .onChange(of: text) { _ in isFocused = !text.isEmpty }
    }
}

struct SuccessOverlay: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            ModernColors.glassDark
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ModernColors.success)
                    .shadow(color: ModernColors.success.opacity(0.6), radius: 10)
                Text(message)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ModernColors.text)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ModernColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ModernColors.success.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: ModernColors.neumorphicShadow, radius: 10)
            .transition(.opacity.combined(with: .scale))
        }
        .animation(.easeInOut(duration: 0.5), value: isPresented)
    }
}

struct ErrorOverlay: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            ModernColors.glassDark
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ModernColors.error)
                    .shadow(color: ModernColors.error.opacity(0.6), radius: 10)
                Text(message)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ModernColors.text)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ModernColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ModernColors.error.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: ModernColors.neumorphicShadow, radius: 10)
            .transition(.opacity.combined(with: .scale))
        }
        .animation(.easeInOut(duration: 0.5), value: isPresented)
    }
}

// Placeholder Extension (Unchanged)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { content() }
            self
        }
    }
}

// Preview
struct FoodInputView_Previews: PreviewProvider {
    static var previews: some View {
        FoodInputView(
            isPresented: .constant(true),
            barcode: "12345",
            userId: 1
        )
    }
}
