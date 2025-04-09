//
//  BarcodeScannedFood.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 31/12/24.
//

import Foundation

struct BarcodeScannedFood: Identifiable {
    let id = UUID()
    let barcode: String
    let displayName: String
    let calories: Int
    let carbs: Double
    let protein: Double
    let fat: Double
    let scannedDate: String
}

func fetchFoodByBarcode(barcode: String, userId: Int, completion: @escaping (Result<BarcodeScannedFood?, Error>) -> Void) {
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

    let parameters = [
        "barcode": barcode,
        "userId": String(userId)
    ]
    .map { "\($0.key)=\($0.value)" }
    .joined(separator: "&")

    print("Sending request to /scanFood with parameters:")
    print(parameters)

    request.httpBody = parameters.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let statusError = NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
            completion(.failure(statusError))
            return
        }

        guard let data = data else {
            let noDataError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
            completion(.failure(noDataError))
            return
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                let parsingError = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response"])
                completion(.failure(parsingError))
                return
            }

            if let success = json["success"] as? Int, success == 1 {
                let food = BarcodeScannedFood(
                    barcode: barcode,
                    displayName: json["foodName"] as? String ?? "",
                    calories: json["calories"] as? Int ?? 0,
                    carbs: (json["carbs"] as? NSNumber)?.doubleValue ?? 0.0,
                    protein: (json["protein"] as? NSNumber)?.doubleValue ?? 0.0,
                    fat: (json["fat"] as? NSNumber)?.doubleValue ?? 0.0,
                    scannedDate: json["scannedDate"] as? String ?? ""
                )
                completion(.success(food))
            } else {
                print("Barcode does not exist, full food details required.")
                print("Sending barcode to FoodInputView from BarcodeScannerFood: \(barcode)")
                
                let message = json["message"] as? String ?? "Unknown error occurred."
                let error = NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                completion(.failure(error))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
