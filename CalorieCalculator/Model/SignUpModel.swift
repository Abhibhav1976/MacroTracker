//
//  SignUpModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import Foundation

struct SignUpResponse: Codable {
    let success: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}

class SignUpModel: ObservableObject {
    @Published var signUpSuccess: Bool = false
    @Published var errorMessage: String? = nil
    
    typealias SignUpCompletion = (Result<SignUpResponse, Error>) -> Void
    
    func signup(username: String, displayName: String, email: String, password: String, completion: @escaping SignUpCompletion) {
        let url = URL(string: "http://35.200.184.145:8080/CalorieCalculator-1.0-SNAPSHOT/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ??  "")&displayName=\(displayName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = parameters.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(.failure(error)) 
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                completion(.failure(noDataError))
                return
            }
            
            do {
                let signUpResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if signUpResponse.success {
                        self.signUpSuccess = true
                    } else {
                        self.errorMessage = signUpResponse.message ?? "Signup failed"
                    }
                    completion(.success(signUpResponse))
                }
            } catch let decodingError as DecodingError {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(decodingError.localizedDescription)"
                }
                completion(.failure(decodingError))
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "General error: \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
