//
//  CollapsibleMealList.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//  Completely Reimagined by Grok 3 (xAI) on March 12, 2025.
//

import SwiftUI

struct CompactMealTimeline: View {
    let macros: [MacroResponse]
    @Binding var expandedMealTypes: Set<String>
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
                if let meals = Dictionary(grouping: macros) { $0.mealType }[mealType] {
                    MealNode(
                        mealType: mealType,
                        meals: meals,
                        isExpanded: Binding(
                            get: { expandedMealTypes.contains(mealType) },
                            set: { isExpanded in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if isExpanded {
                                        expandedMealTypes.insert(mealType)
                                    } else {
                                        expandedMealTypes.remove(mealType)
                                    }
                                }
                            }
                        )
                    )
                }
            }
        }
    }
}

struct MealNode: View {
    let mealType: String
    let meals: [MacroResponse]
    @Binding var isExpanded: Bool
    
    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var macroSummary: String {
        let carbs = meals.reduce(0) { $0 + $1.carbs }
        let protein = meals.reduce(0) { $0 + $1.protein }
        let fat = meals.reduce(0) { $0 + $1.fat }
        return "C:\(carbs) P:\(protein) F:\(fat)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(isExpanded ? LogColors.neonPulse : LogColors.slateGlow)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(LogColors.neonPulse.opacity(0.5), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealType)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(LogColors.brightHaze)
                        if !isExpanded {
                            Text("\(totalCalories) cal • \(macroSummary)")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(LogColors.mutedAsh)
                        }
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(LogColors.slateGlow)
                .cornerRadius(12)
            }
            .pulseButton()
            
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(meals, id: \.uniqueId) { meal in
                        MealEntry(meal: meal)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(LogColors.deepVoid)
                .cornerRadius(12)
            }
        }
        .floatingCard()
    }
}

struct MealEntry: View {
    let meal: MacroResponse
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(meal.calories)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(LogColors.neonPulse)
            Text("cal")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(LogColors.mutedAsh)
            
            Spacer()
            
            Text("C:\(meal.carbs) P:\(meal.protein) F:\(meal.fat)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(LogColors.brightHaze)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(LogColors.slateGlow.opacity(0.5))
        .cornerRadius(8)
    }
}
