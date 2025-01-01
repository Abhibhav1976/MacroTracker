//
//  FoodLoggingView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//

import SwiftUI

struct FoodLoggingView: View {
    @Binding var isPresented: Bool
    @State private var servingAmount: String = ""
    @State private var selectedMealType: String = ""
    @State private var showSuccess: Bool = false
    
    let foodItem: FoodItem
    @EnvironmentObject var macrosModel: Macros
    let userId = UserDefaults.standard.integer(forKey: "UserId")
    
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    
    private var calculatedMacros: MacroInfo {
        let multiplier = (Double(servingAmount) ?? 0) / foodItem.standardServing.amount
        let baseMacros = foodItem.standardServing.macros
        return MacroInfo(
            calories: Int(Double(baseMacros.calories) * multiplier),
            fat: baseMacros.fat * multiplier,
            carbs: baseMacros.carbs * multiplier,
            protein: baseMacros.protein * multiplier
        )
    }
    
    var body: some View {
        if showSuccess {
            SuccessView(
                message: "Food has been logged successfully",
                isPresented: $isPresented
            )
        } else {
            PopupView(title: "Log Food", isPresented: $isPresented) {
                VStack(spacing: 20) {
                    Text(foodItem.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Meal Type")
                            .foregroundColor(ColorPalette.subtext)
                        
                        HStack {
                            ForEach(mealTypes, id: \.self) { type in
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
                            placeholder: "Amount (\(foodItem.standardServing.unit))",
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
