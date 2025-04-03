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
    @State private var appearAnimation: Bool = false
    
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
                ScrollView {
                    VStack(spacing: 32) {
                        // Title with animation
                        Text(foodItem.displayName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ModernColors.text)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                        
                        // Meal type grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(mealTypes.indices, id: \.self) { index in
                                LMealTypeIcon(
                                    type: mealTypes[index],
                                    isSelected: selectedMealType == mealTypes[index],
                                    action: { selectedMealType = mealTypes[index] },
                                    angle: Double(index) * 90
                                )
                                .offset(x: appearAnimation ? 0 : 50)
                                .opacity(appearAnimation ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1),
                                    value: appearAnimation
                                )
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // Serving input
                        VStack(spacing: 20) {
                            ModernTextField(
                                placeholder: "Amount (\(foodItem.standardServing.unit))",
                                text: $servingAmount,
                                keyboardType: .decimalPad
                            )
                            .offset(y: appearAnimation ? 0 : 30)
                            .opacity(appearAnimation ? 1 : 0)
                        }
                        
                        // Calculated macros display
                        VStack(spacing: 20) {
                            // Calories
                            VStack(spacing: 4) {
                                Text("Total Calories")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(ModernColors.muted)
                                
                                Text("\(calculatedMacros.calories) kcal")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(ModernColors.text)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(ModernColors.surface)
                            .cornerRadius(16)
                            
                            // Macros grid
                            HStack(spacing: 12) {
                                MacroCardFood(
                                    title: "Protein",
                                    value: String(format: "%.1fg", calculatedMacros.protein),
                                    icon: "figure.strengthtraining.traditional",
                                    color: Color(hex: "FF6B6B")
                                )
                                
                                MacroCardFood(
                                    title: "Carbs",
                                    value: String(format: "%.1fg", calculatedMacros.carbs),
                                    icon: "leaf.fill",
                                    color: Color(hex: "4FACFE")
                                )
                            }
                            
                            HStack(spacing: 12) {
                                MacroCardFood(
                                    title: "Fat",
                                    value: String(format: "%.1fg", calculatedMacros.fat),
                                    icon: "drop.fill",
                                    color: Color(hex: "8B5CF6")
                                )
                            }
                        }
                        .offset(y: appearAnimation ? 0 : 30)
                        .opacity(appearAnimation ? 1 : 0)
                        
                        // Save button
                        Button(action: submitFood) {
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
                        .disabled(servingAmount.isEmpty || selectedMealType.isEmpty)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                    }
                    .padding(24)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    appearAnimation = true
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

// MARK: - MealTypeIcon (Reimagined)
struct LMealTypeIcon: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    let angle: Double
    
    private var iconName: String {
        switch type {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "sun.max.fill"
        case "Dinner": return "moon.fill"
        case "Snacks": return "leaf.fill"
        default: return ""
        }
    }
    
    private var gradientColors: [Color] {
        switch type {
        case "Breakfast": return [ModernColors.primary, ModernColors.neonPulse]
        case "Lunch": return [ModernColors.secondary, ModernColors.cosmicGlow]
        case "Dinner": return [ModernColors.accent, ModernColors.neonPulse]
        case "Snacks": return [ModernColors.tertiary, ModernColors.cosmicGlow]
        default: return [ModernColors.muted]
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: gradientColors[0].opacity(isSelected ? 0.7 : 0.3), radius: 8)
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(ModernColors.text)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
            }
        }
        .offset(
            x: cos(angle * .pi / 180) * 80,
            y: sin(angle * .pi / 180) * 80
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

// Helper view for macro cards
struct MacroCardFood: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ModernColors.muted)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ModernColors.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(ModernColors.surface)
        .cornerRadius(16)
    }
}
