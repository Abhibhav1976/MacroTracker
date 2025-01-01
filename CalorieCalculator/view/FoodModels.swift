//
//  FoodModels.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//

import Foundation

struct ServingInfo: Codable, Hashable {
    let amount: Double
    let unit: String
    let macros: MacroInfo
}

struct MacroInfo: Codable, Hashable {
    let calories: Int
    let fat: Double
    let carbs: Double
    let protein: Double
}

struct FoodItem: Codable, Identifiable, Hashable {
    let foodId: String?
    let foodName: String?
    let foodDescription: String?
    let foodType: String?
    let brandName: String?
    let foodUrl: String?
    
    private let instanceId = UUID().uuidString
    private let _macros: MacroInfo
    private let _standardServing: ServingInfo
    
    var id: String {
        if let foodId = foodId {
            return "\(foodId)_\(instanceId)"
        }
        return instanceId
    }
    
    var displayName: String {
        foodName ?? "Unnamed Food"
    }
    
    var standardServing: ServingInfo {
        _standardServing
    }
    
    private static func parseServingInfo(from description: String?) -> (amount: Double, unit: String) {
        guard let desc = description else { return (100, "g") }
        
        let pattern = /Per\s+(\d+\.?\d*)\s*([a-zA-Z]+|\w+\s+\w+)/
        if let match = try? desc.firstMatch(of: pattern) {
            let amount = Double(match.1) ?? 100
            let unit = String(match.2)
            return (amount, unit)
        }
        return (100, "g")
    }
    
    private static func calculateMacros(from description: String?) -> MacroInfo {
        guard let desc = description else {
            return MacroInfo(calories: 0, fat: 0, carbs: 0, protein: 0)
        }
        
        let patterns = [
            "calories": /Calories:\s*(\d+)\s*kcal/,
            "fat": /Fat:\s*(\d+\.?\d*)/,
            "carbs": /Carbs:\s*(\d+\.?\d*)/,
            "protein": /Protein:\s*(\d+\.?\d*)/
        ]
        
        let calories = (try? desc.firstMatch(of: patterns["calories"]!)?.1).flatMap { Int($0) } ?? 0
        let fat = (try? desc.firstMatch(of: patterns["fat"]!)?.1).flatMap { Double($0) } ?? 0
        let carbs = (try? desc.firstMatch(of: patterns["carbs"]!)?.1).flatMap { Double($0) } ?? 0
        let protein = (try? desc.firstMatch(of: patterns["protein"]!)?.1).flatMap { Double($0) } ?? 0
        
        return MacroInfo(calories: calories, fat: fat, carbs: carbs, protein: protein)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        foodId = try container.decodeIfPresent(String.self, forKey: .foodId)
        foodName = try container.decodeIfPresent(String.self, forKey: .foodName)
        foodDescription = try container.decodeIfPresent(String.self, forKey: .foodDescription)
        foodType = try container.decodeIfPresent(String.self, forKey: .foodType)
        brandName = try container.decodeIfPresent(String.self, forKey: .brandName)
        foodUrl = try container.decodeIfPresent(String.self, forKey: .foodUrl)
        
        let servingInfo = Self.parseServingInfo(from: foodDescription)
        _macros = Self.calculateMacros(from: foodDescription)
        _standardServing = ServingInfo(
            amount: servingInfo.amount,
            unit: servingInfo.unit,
            macros: _macros
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case foodId = "food_id"
        case foodName = "food_name"
        case foodDescription = "food_description"
        case foodType = "food_type"
        case brandName = "brand_name"
        case foodUrl = "food_url"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        lhs.id == rhs.id
    }
}
struct FoodResponse: Codable {
    let foods: Foods
    
    struct Foods: Codable {
        let food: [FoodItem]
    }
}
