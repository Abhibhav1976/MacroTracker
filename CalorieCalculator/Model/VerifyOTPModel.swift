//
//  VerifyOTPModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 15/04/25.
//

import Foundation

struct VerifyOTPResponse: Codable {
    let success: Bool
    let message: String

    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}

class VerifyOTPModel: ObservableObject {
    @Published var otp: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isVerified: Bool = false
    
    private let email: String
    
    init(email: String) {
        self.email = email
    }
    
    typealias VerifyOTPCompletion = (Result<VerifyOTPResponse, Error>) -> Void
    
    func verifyOTP(completion: @escaping VerifyOTPCompletion) {
        guard !otp.isEmpty else {
            errorMessage = "OTP is required"
            completion(.failure(NSError(domain: "VerifyOTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP is required"])))
            return
        }

        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/verify-otp") else {
            errorMessage = "Invalid URL"
            completion(.failure(NSError(domain: "VerifyOTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "email": email,
            "otp": otp
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
                    let noDataError = NSError(domain: "VerifyOTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    DispatchQueue.main.async {
                        self.errorMessage = "No data received"
                    }
                    completion(.failure(noDataError))
                    return
                }

                do {
                    let verifyResponse = try JSONDecoder().decode(VerifyOTPResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.isVerified = verifyResponse.success
                        self.errorMessage = verifyResponse.success ? nil : verifyResponse.message
                        completion(.success(verifyResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    }
                    completion(.failure(error))
                }
            }.resume()
        }

        performRequest()
    }
}
