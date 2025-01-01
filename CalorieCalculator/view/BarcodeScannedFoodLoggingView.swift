//
//  BarcodeScannedFoodLoggingView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 31/12/24.
//

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

    // Custom decoding to handle default value for `amount`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 100
        self.unit = try container.decode(String.self, forKey: .unit)
        self.macros = try container.decode(CalculatedMacros.self, forKey: .macros)
    }

    // Encoding is straightforward, no changes required
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
        
        // Calculate multiplier based on serving size (100g is base) Need to add More Serving Options later
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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Meal Type")
                            .foregroundColor(ColorPalette.subtext)

                        HStack {
                            ForEach(mealTypes, id: \ .self) { type in
                                Button(action: { selectedMealType = type }) {
                                    Text(type)
                                        .foregroundColor(selectedMealType == type ? .white : ColorPalette.subtext)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            selectedMealType == type ?
                                                ColorPalette.primaryButton :
                                                Color(hex: "#1E1E1E")
                                        )
                                        .cornerRadius(8)
                                }
                            }
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
