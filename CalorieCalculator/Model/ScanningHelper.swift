//
//  ScanningHelper.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 31/12/24.
//

import Foundation

struct ScannedFood {
    let foodName: String
    let calories: Int
    let carbs: Double
    let protein: Double
    let fat: Double
    let success: Bool
    let message: String
}

struct LoggedFoodItem {
    var barcode: String
    var displayName: String
    var calories: Int
    var carbs: Double
    var protein: Double
    var fat: Double
    var scannedDate: String
    var standardServing: Serving?
}

// Helper function to calculate calories from macros
func calculateCalories(carbs: Double, protein: Double, fat: Double) -> Int {
    return Int((carbs * 4) + (protein * 4) + (fat * 9))
}

func fetchFoodInfo(
    barcode: String,
    foodName: String,
    calories: Int,
    carbs: Double,
    protein: Double,
    fat: Double,
    userId: Int,
    completion: @escaping (Result<ScannedFood, Error>) -> Void
) {
    guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/scanFood") else {
        let urlError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        completion(.failure(urlError))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    print("Preparing to send food info to server with the following data:")
    print("Barcode: \(barcode)")
    print("UserID: \(userId)")
    print("Food Name: \(foodName)")
    print("Calories: \(calories), Carbs: \(carbs), Protein: \(protein), Fat: \(fat)")

    let parameters = [
        "barcode": barcode,
        "foodName": foodName,
        "calories": String(calories),
        "carbs": String(carbs),
        "protein": String(protein),
        "fat": String(fat),
        "userId": String(userId)
    ]
    .map { key, value in "\(key)=\(value)" }
    .joined(separator: "&")

    request.httpBody = parameters.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            let noDataError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
            completion(.failure(noDataError))
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let success = json["success"] as? Bool else {
                    let parseError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format: missing success flag"])
                    completion(.failure(parseError))
                    return
                }

                let message = json["message"] as? String ?? "Unknown error"
                
                if !success {
                    // Server returned an error (e.g., "Barcode and User ID are required")
                    let serverError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                    print("Server error: \(message)")
                    completion(.failure(serverError))
                    return
                }

                // Success case
                let scannedFood = ScannedFood(
                    foodName: json["foodName"] as? String ?? "",
                    calories: json["calories"] as? Int ?? 0,
                    carbs: (json["carbs"] as? NSNumber)?.doubleValue ?? 0.0,
                    protein: (json["protein"] as? NSNumber)?.doubleValue ?? 0.0,
                    fat: (json["fat"] as? NSNumber)?.doubleValue ?? 0.0,
                    success: success,
                    message: message // e.g., "Food scanned successfully"
                )
                print("Successfully saved food: \(scannedFood.foodName)")
                completion(.success(scannedFood))
            } else {
                let jsonError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                completion(.failure(jsonError))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
