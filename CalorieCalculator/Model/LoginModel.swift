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
    let displayName: String?
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
    let memberType: String?
    let streak: Int?
    let lastLoggedDate: String?
    let error: String?
    let token: String? // Added token field

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case userId = "userId"
        case username
        case password
        case displayName = "displayName"
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
        case memberType
        case streak
        case lastLoggedDate
        case error
        case token // Added token case
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
        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/login") else {
            let urlError = NSError(domain: "LoginError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = parameters.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                print("URLError: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "LoginError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }
            
            // Log HTTP status code and response headers
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let httpError = NSError(domain: "LoginError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error with status code: \(httpResponse.statusCode)"])
                    completion(.failure(httpError))
                    return
                }
            }
            
            // Log raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if userResponse.success == true,
                       let id = userResponse.userId,
                       let memberType = userResponse.memberType,
                       let streak = userResponse.streak {
                        self.userResponse = userResponse
                        self.loginSuccess = true
                        
                        if let jsonData = try? JSONEncoder().encode(userResponse) {
                            UserDefaults.standard.set(jsonData, forKey: "userResponse")
                        }
                        
                        if let token = userResponse.token { // Store token
                            UserDefaults.standard.set(token, forKey: "authToken")
                        }
                        
                        UserDefaults.standard.set(true, forKey: "loginSuccess")
                        UserDefaults.standard.set(id, forKey: "UserId")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.set(memberType, forKey: "memberType")
                        UserDefaults.standard.set(streak, forKey: "streak")
                        
                        UserDefaults.standard.synchronize()
                        
                        completion(.success(userResponse))
                    } else {
                        let message = userResponse.message ?? "Unknown error occurred"
                        completion(.failure(NSError(domain: "LoginError", code: 2, userInfo: [NSLocalizedDescriptionKey: message])))
                    }
                }
            } catch let decodingError as DecodingError {
                print("Decoding Error: \(decodingError.localizedDescription)")
                
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Missing key '\(key.stringValue)' – \(context.debugDescription)")
                case .typeMismatch(_, let context):
                    print("Type mismatch: \(context.debugDescription)")
                case .valueNotFound(_, let context):
                    print("Value not found: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }

                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response causing error:\n\(raw)")
                }

                completion(.failure(decodingError))
            } catch {
                print("General error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    func validateToken(completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("No token found in UserDefaults")
            completion(false)
            return
        }

        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/validateToken") else {
            print("Invalid validateToken URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = "token=\(token)"
        request.httpBody = parameters.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Token validation error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received for token validation")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("ValidateToken HTTP Status: \(httpResponse.statusCode)")
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw validateToken response: \(rawResponse)")
            }

            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)

                DispatchQueue.main.async {
                    self.userResponse = userResponse // Update the userResponse
                    self.loginSuccess = true

                    // Store the user data in UserDefaults
                    if let jsonData = try? JSONEncoder().encode(userResponse) {
                        UserDefaults.standard.set(jsonData, forKey: "userResponse")
                    }
                    print("Age received in token response:", userResponse.age ?? -1)
                    // Store the token in UserDefaults
                    if let token = userResponse.token {
                        UserDefaults.standard.set(token, forKey: "authToken")
                    }

                    // Store individual user details in UserDefaults
                    if let userId = userResponse.userId {
                        UserDefaults.standard.set(userId, forKey: "UserId")
                    }
                    if let username = userResponse.username {
                        UserDefaults.standard.set(username, forKey: "username")
                    }
                    if let password = userResponse.password {
                        UserDefaults.standard.set(password, forKey: "password")
                    }
                    if let memberType = userResponse.memberType {
                        UserDefaults.standard.set(memberType, forKey: "memberType")
                    }
                    if let streak = userResponse.streak {
                        UserDefaults.standard.set(streak, forKey: "streak")
                    }

                    // Ensure UserDefaults are synchronized
                    UserDefaults.standard.synchronize()

                    // Trigger the UI update by notifying that data is updated
                    completion(true)
                }
            } catch {
                print("Token validation parse error: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
}
extension LoginModel {
    func logout() {
        // Clear stored session data
        UserDefaults.standard.removeObject(forKey: "loginSuccess")
        UserDefaults.standard.removeObject(forKey: "UserId")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.removeObject(forKey: "userResponse")
        UserDefaults.standard.removeObject(forKey: "authToken") // Remove token
        UserDefaults.standard.synchronize()

        // Reset model state
        DispatchQueue.main.async {
            self.loginSuccess = false
            self.userId = nil
            self.userResponse = nil
        }
    }
}
