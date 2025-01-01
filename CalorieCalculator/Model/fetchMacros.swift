//
//  fetchMacros.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 26/12/24.
//

import Foundation

struct MacroResponse: Codable {
  let userId: Int
  let entryDate: String
  let mealType: String
  let calories: Int
  let carbs: Int
  let protein: Int
  let fat: Int
}

class Macros: ObservableObject {
    @Published var macros: [MacroResponse] = []
    @Published var fetchSuccess: Bool = false
    @Published var addSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var lastScannedBarcode: String?

  func fetchMacros(userId: Int, entryDate: String, completion: @escaping (Result<[MacroResponse], Error>) -> Void) {
    guard let url = URL(string: "https://d303-2401-4900-1c0a-634b-6c67-ffd-63e8-5a9.ngrok-free.app/CalorieCalculator-1.0-SNAPSHOT/FindMacro") else {
      print("Invalid URL") // Debug
      completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let parameters = "userId=\(userId)&entryDate=\(entryDate)"
    print("Request parameters: \(parameters)") // Debug
    request.httpBody = parameters.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Network error: \(error.localizedDescription)") // Debug
        DispatchQueue.main.async {
          self.errorMessage = error.localizedDescription
          self.fetchSuccess = false
          completion(.failure(error))
        }
        return
      }
        /*
      if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
        print("Raw server response: \(rawResponse)") // Debug: Print raw response
      }
         */
         
      guard let data = data else {
        print("No data received") // Debug
        let noDataError = NSError(domain: "Fetch Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
        DispatchQueue.main.async {
          self.errorMessage = "No data received"
          self.fetchSuccess = false
          completion(.failure(noDataError))
        }
        return
      }

      do {
        let macroResponses = try JSONDecoder().decode([MacroResponse].self, from: data)
        print("Successfully decoded \(macroResponses.count) macro responses") // Debug
        DispatchQueue.main.async {
          self.macros = macroResponses
          self.fetchSuccess = true
          self.errorMessage = nil
          completion(.success(macroResponses))
        }
      } catch {
        print("Decoding error: \(error)") // Debug
        DispatchQueue.main.async {
          self.errorMessage = error.localizedDescription
          self.fetchSuccess = false
          completion(.failure(error))
        }
      }
    }.resume()
  }
    func addMacros(
        userId: Int,
        entryDate: String,
        mealType: String,
        calories: Int,
        carbs: Int,
        protein: Int,
        fat: Int,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let url = URL(string: "https://d303-2401-4900-1c0a-634b-6c67-ffd-63e8-5a9.ngrok-free.app/CalorieCalculator-1.0-SNAPSHOT/LogMacro") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "userId": userId,
            "entryDate": entryDate,
            "mealType": mealType,
            "calories": calories,
            "carbs": carbs,
            "protein": protein,
            "fat": fat
        ]
        .map { key, value in "\(key)=\(value)" }
        .joined(separator: "&")

        print("Request parameters: \(parameters)") // Debug
        request.httpBody = parameters.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)") // Debug
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.addSuccess = false
                    completion(.failure(error))
                }
                return
            }

            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw server response: \(rawResponse)") // Debug
            }

            guard let data = data else {
                print("No data received") // Debug
                let noDataError = NSError(domain: "Add Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.addSuccess = false
                    completion(.failure(noDataError))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    DispatchQueue.main.async {
                        self.addSuccess = success
                        self.errorMessage = success ? nil : (json["message"] as? String ?? "Unknown error")
                        completion(.success(success))
                    }
                } else {
                    throw NSError(domain: "Parse Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
            } catch {
                print("Decoding error: \(error)") // Debug
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.addSuccess = false
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
