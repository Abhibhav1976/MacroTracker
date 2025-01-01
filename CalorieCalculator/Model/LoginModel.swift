//
//  LoginModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import Foundation

// MARK: - UserResponse
struct UserResponse: Codable {
    let success: Bool
    let message: String?
    let userId: Int?
    let username: String?
    let password: String?
    let email: String?
    let age: Int?
    let currentWeight: Double?
    let targetWeight: Double?
    let requiredCalories: Int?
    let height: Double?
    let activityLevel: String?
    let gender: String?
    let goalType: String?
    let profilePicture: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case userId = "userId"
        case username
        case password
        case email
        case age
        case currentWeight
        case targetWeight
        case requiredCalories
        case height
        case activityLevel
        case gender
        case goalType
        case profilePicture
        case error
    }
}

// MARK: - LoginModel
class LoginModel: ObservableObject {
    @Published var loginSuccess: Bool = false
    @Published var errorMessage: String? = nil
    @Published var userId: Int? = nil
    @Published var userResponse: UserResponse?
    
    typealias LoginCompletion = (Result<UserResponse, Error>) -> Void
    
    func login(username: String, password: String, completion: @escaping LoginCompletion) {
        let url = URL(string: "https://d303-2401-4900-1c0a-634b-6c67-ffd-63e8-5a9.ngrok-free.app/CalorieCalculator-1.0-SNAPSHOT/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = parameters.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "LoginError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }
            
            // Log raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if userResponse.success, let id = userResponse.userId {  // Fixing "UserId" to "userId"
                        self.userResponse = userResponse
                        self.loginSuccess = true
                        
                        UserDefaults.standard.set(true, forKey: "loginSuccess")
                        UserDefaults.standard.set(id, forKey: "UserId")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(username, forKey: "username")
                        
                        UserDefaults.standard.synchronize()
                        
                        completion(.success(userResponse))
                    } else {
                        completion(.failure(NSError(domain: "LoginError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
                    }
                }
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    print("Missing key: \(key.stringValue)")
                case .typeMismatch(_, let context), .valueNotFound(_, let context):
                    print("Type mismatch or value not found: \(context.debugDescription)")
                default:
                    print("Decoding error: \(decodingError.localizedDescription)")
                }
                completion(.failure(decodingError))
            } catch {
                print("General error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
