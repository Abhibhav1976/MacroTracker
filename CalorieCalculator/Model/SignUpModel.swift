//
//  SignUpModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import Foundation

struct SignUpResponse: Codable {
    let success: Bool
    let message: String

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
        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/signup") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "username": username,
            "displayName": displayName,
            "email": email,
            "password": password
        ]

        let encodedParams = parameters
            .compactMap { key, value in
                guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
                return "\(key)=\(escapedValue)"
            }
            .joined(separator: "&")

        request.httpBody = encodedParams.data(using: .utf8)

        let maxRetries = 2
        var attempt = 0

        func performRequest() {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if attempt < maxRetries {
                        attempt += 1
                        performRequest()
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Network error: \(error.localizedDescription)"
                        }
                        completion(.failure(error))
                        return
                    }
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
                            self.errorMessage = nil
                        } else {
                            self.errorMessage = signUpResponse.message
                        }
                        completion(.success(signUpResponse))
                    }
                } catch let decodingError {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse response: \(decodingError.localizedDescription)"
                    }
                    completion(.failure(decodingError))
                }
            }.resume()
        }

        performRequest()
    }
}
