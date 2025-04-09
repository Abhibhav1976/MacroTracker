import SwiftUI

struct CalculatedMacros: Codable {
    let calories: Int
    let fat: Double
    let carbs: Double
    let protein: Double
}

struct Serving: Codable {
    let amount: Double
    let unit: String
    let macros: CalculatedMacros

    init(amount: Double = 100, unit: String, macros: CalculatedMacros) {
        self.amount = amount
        self.unit = unit
        self.macros = macros
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 100
        self.unit = try container.decode(String.self, forKey: .unit)
        self.macros = try container.decode(CalculatedMacros.self, forKey: .macros)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(unit, forKey: .unit)
        try container.encode(macros, forKey: .macros)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, unit, macros
    }
}

struct BarcodeScannedFoodLoggingView: View {
    @Binding var isPresented: Bool
    @State private var servingAmount: String = "100"
    @State private var selectedMealType: String = ""
    @State private var showSuccess: Bool = false
    @State private var isLoading = true
    @State private var errorMessage: String?

    let foodItem: LoggedFoodItem
    init(isPresented: Binding<Bool>, foodItem: LoggedFoodItem) {
        self._isPresented = isPresented
        self.foodItem = foodItem
        print("Initialized BarcodeScannedFoodLoggingView with:")
        print("Name: \(foodItem.displayName), Calories: \(foodItem.calories)")
        print("Carbs: \(foodItem.carbs), Protein: \(foodItem.protein), Fat: \(foodItem.fat)")
    }

    @EnvironmentObject var macrosModel: Macros
    let userId = UserDefaults.standard.integer(forKey: "UserId")
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]

    private var calculatedMacros: CalculatedMacros {
        guard let amount = Double(servingAmount) else {
            return CalculatedMacros(calories: 0, fat: 0, carbs: 0, protein: 0)
        }
        
        let multiplier = amount / 100.0
        
        return CalculatedMacros(
            calories: Int(Double(foodItem.calories) * multiplier),
            fat: foodItem.fat * multiplier,
            carbs: foodItem.carbs * multiplier,
            protein: foodItem.protein * multiplier
        )
    }

    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Food has been logged successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Log Scanned Food", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text(foodItem.displayName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(ModernColors.text)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(ModernColors.glassLight)
                                .shadow(color: ModernColors.neonPulse.opacity(0.4), radius: 6)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .shadow(color: ModernColors.neonPulse.opacity(0.3), radius: 4)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Spacer()
                            ForEach(mealTypes, id: \.self) { type in
                                BarcodeMealTypeIcon(
                                    type: type,
                                    isSelected: selectedMealType == type,
                                    action: { selectedMealType = type }
                                )
                            }
                            Spacer()
                        }
                        
                        StyledTextField(
                            placeholder: "Amount (\(foodItem.standardServing?.unit ?? "unknown unit"))",
                            text: $servingAmount,
                            keyboardType: .decimalPad
                        )
                        
                        HStack(spacing: 12) {
                            StatItem(title: "Calories", value: "\(calculatedMacros.calories)", icon: "flame.fill")
                            StatItem(title: "Protein", value: String(format: "%.1fg", calculatedMacros.protein), icon: "figure.strengthtraining.traditional")
                        }

                        HStack(spacing: 12) {
                            StatItem(title: "Carbs", value: String(format: "%.1fg", calculatedMacros.carbs), icon: "leaf.fill")
                            StatItem(title: "Fat", value: String(format: "%.1fg", calculatedMacros.fat), icon: "drop.fill")
                        }

                        Button(action: submitFood) {
                            Text("Save")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ColorPalette.primaryButton)
                                .cornerRadius(12)
                        }
                        .disabled(servingAmount.isEmpty || selectedMealType.isEmpty)
                    }
                }
            }
        }
    }

    private func submitFood() {
        guard !servingAmount.isEmpty, !selectedMealType.isEmpty else { return }

        macrosModel.addMacros(
            userId: userId,
            entryDate: currentDate,
            mealType: selectedMealType,
            calories: calculatedMacros.calories,
            carbs: Int(round(calculatedMacros.carbs)),
            protein: Int(round(calculatedMacros.protein)),
            fat: Int(round(calculatedMacros.fat))
        ) { result in
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                print("Error logging food: \(error.localizedDescription)")
            }
        }
    }

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// Helper View: BarcodeMealTypeIcon (Unchanged)
struct BarcodeMealTypeIcon: View {
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

// Preview
struct BarcodeScannedFoodLoggingView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannedFoodLoggingView(
            isPresented: .constant(true),
            foodItem: LoggedFoodItem(
                barcode: "12345",
                displayName: "Sample Food",
                calories: 200,
                carbs: 30.0,
                protein: 10.0,
                fat: 5.0,
                scannedDate: "2024-04-09",
                standardServing: Serving(amount: 100, unit: "g", macros: CalculatedMacros(calories: 200, fat: 5.0, carbs: 30.0, protein: 10.0))
            )
        )
        .environmentObject(Macros())
    }
}
