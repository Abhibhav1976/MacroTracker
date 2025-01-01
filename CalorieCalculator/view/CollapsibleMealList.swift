//
//  CollapsibleMealList.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//

import SwiftUI

struct MealSection: View {
    let mealType: String
    let meals: [MacroResponse]
    let isExpanded: Bool
    let onToggle: (Bool) -> Void
    
    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var macroSummary: String {
        let carbs = meals.reduce(0) { $0 + $1.carbs }
        let protein = meals.reduce(0) { $0 + $1.protein }
        let fat = meals.reduce(0) { $0 + $1.fat }
        return "\(carbs)g C • \(protein)g P • \(fat)g F"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { onToggle(!isExpanded) }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealType)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if !isExpanded {
                            Text(macroSummary)
                                .font(.caption)
                                .foregroundColor(ColorPalette.subtext)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(totalCalories) cal")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(ColorPalette.secondaryButton)
                        .padding(.leading)
                }
            }
            .padding()
            .background(ColorPalette.cardBackground)
            
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(meals, id: \.uniqueId) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
        }
        .background(ColorPalette.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MealRow: View {
    let meal: MacroResponse
    
    var body: some View {
        HStack {
            Text("\(meal.calories) calories")
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Carbs: \(meal.carbs)g  • Protein: \(meal.protein)g • Fat: \(meal.fat)g")
                .foregroundColor(ColorPalette.subtext)
                .font(.caption)
        }
        .padding()
        .background(ColorPalette.background)
    }
}
