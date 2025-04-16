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
        print("Signup attempt: username=\(username), email=\(email), displayName=\(displayName)")
        
        guard !username.isEmpty, !displayName.isEmpty, !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "All fields are required"
                print("Validation failed: Missing fields")
            }
            completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "All fields are required"])))
            return
        }

        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/signup") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                print("Invalid URL")
            }
            completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
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
                        print("Retry \(attempt) for email: \(email)")
                        performRequest()
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Network error: \(error.localizedDescription)"
                            print("Network error: \(error.localizedDescription)")
                        }
                        completion(.failure(error))
                        return
                    }
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let noResponseError = NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
                    DispatchQueue.main.async {
                        self.errorMessage = "No HTTP response"
                        print("No HTTP response")
                    }
                    completion(.failure(noResponseError))
                    return
                }

                print("HTTP status: \(httpResponse.statusCode)")
                if let headers = httpResponse.allHeaderFields as? [String: String] {
                    print("Response headers: \(headers)")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusError = NSError(domain: "SignUpError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: HTTP \(httpResponse.statusCode)"])
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error: HTTP \(httpResponse.statusCode)"
                        print("Server error: HTTP \(httpResponse.statusCode)")
                    }
                    if let data = data, let rawString = String(data: data, encoding: .utf8) {
                        print("Raw response: \(rawString)")
                    }
                    completion(.failure(statusError))
                    return
                }

                guard let data = data else {
                    let noDataError = NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    DispatchQueue.main.async {
                        self.errorMessage = "No data received"
                        print("No data received")
                    }
                    completion(.failure(noDataError))
                    return
                }

                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawString)")
                } else {
                    print("Raw response: Unable to decode data")
                }

                do {
                    let signUpResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.signUpSuccess = signUpResponse.success
                        self.errorMessage = signUpResponse.success ? nil : signUpResponse.message
                        print("Parsed response: success=\(signUpResponse.success), message=\(signUpResponse.message)")
                    }
                    completion(.success(signUpResponse))
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                        print("Parse error: \(error.localizedDescription)")
                    }
                    completion(.failure(error))
                }
            }.resume()
        }

        performRequest()
    }
}
