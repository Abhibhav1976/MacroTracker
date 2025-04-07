//
//  UpdateModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 29/12/24.
//

import Foundation

// MARK: - UpdateModel
class UpdateModel: ObservableObject {
    @Published var updateSuccess: Bool = false
    @Published var errorMessage: String? = nil
    
    typealias UpdateCompletion = (Result<UserResponse, Error>) -> Void
    
    func updateProfile(age: Int?, currentWeight: Double?, targetWeight: Double?, requiredCalories: Int?, height: Double?, activityLevel: String?, gender: String?, goalType: String?, profilePicture: String?, completion: @escaping UpdateCompletion) {
        
        guard let userId = UserDefaults.standard.value(forKey: "UserId") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String,
              let password = UserDefaults.standard.value(forKey: "password") as? String else {
            self.errorMessage = "User data not found in UserDefaults"
            completion(.failure(NSError(domain: "UpdateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
            return
        }
        
        let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/UpdateProfile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var parameters = "userId=\(userId)"
        
        if let age = age {
            parameters += "&age=\(age)"
        }
        if let currentWeight = currentWeight {
            parameters += "&currentWeight=\(currentWeight)"
        }
        if let targetWeight = targetWeight {
            parameters += "&targetWeight=\(targetWeight)"
        }
        if let requiredCalories = requiredCalories {
            parameters += "&requiredCalories=\(requiredCalories)"
        }
        if let height = height {
            parameters += "&height=\(height)"
        }
        if let activityLevel = activityLevel {
            parameters += "&activityLevel=\(activityLevel)"
        }
        if let gender = gender {
            parameters += "&gender=\(gender)"
        }
        if let goalType = goalType {
            parameters += "&goalType=\(goalType)"
        }
        if let profilePicture = profilePicture {
            parameters += "&profilePicture=\(profilePicture)"
        }
        
        request.httpBody = parameters.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "UpdateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                completion(.failure(noDataError))
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if userResponse.success {
                        self.updateSuccess = true
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = userResponse.message ?? "Unknown error occurred"
                    }
                }
                
                completion(.success(userResponse))
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    print("Missing key: \(key.stringValue)")
                case .typeMismatch(_, let context), .valueNotFound(_, let context):
                    print("Type mismatch or value not found: \(context.debugDescription)")
                default:
                    print("Decoding error: \(decodingError.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.errorMessage = decodingError.localizedDescription
                }
                completion(.failure(decodingError))
            } catch {
                print("General error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
