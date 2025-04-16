//
//  ImageScaling.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 08/04/25.
//

import UIKit
import Foundation

extension UIImage {
    func scaledTo720p() -> UIImage? {
        let maxDimension: CGFloat = 1280 // 720p is 1280x720 or 720x1280
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > 1 {
            // Landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // Portrait or square
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }
}

struct ImageQueryResult: Codable {
    let label: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let message: String
}

extension UIImage {
    func sendToServer(entryDate: String, completion: @escaping (Result<ImageQueryResult, Error>) -> Void) {
        guard let scaledImage = self.scaledTo720p(),
              let imageData = scaledImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ScalingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to scale or encode image."])))
            return
        }

        let base64String = imageData.base64EncodedString()
        guard let userId = UserDefaults.standard.integer(forKey: "UserId") as Int?,
              let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/ImageQuery") else {
            completion(.failure(NSError(domain: "UserDefaultsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing userId or invalid URL."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")

        let jsonPayload: [String: Any] = [
            "userId": userId,
            "entryDate": entryDate,
            "base64Image": base64String
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                if let nsError = error as NSError?, nsError.code == 403 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("ImageQueryLimitReachedNotification"), object: nil)
                    }
                } else {
                    print("Image query failed: \(error.localizedDescription)")
                }
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔁 Server responded with status: \(httpResponse.statusCode)")
                if let data = data {
                    print("📨 Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                }
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "ImageQueryError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(statusCode)"])
                
                if statusCode == 403 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("ImageQueryLimitReachedNotification"), object: nil)
                    }
                }

                completion(.failure(error))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "ImageQueryError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
                completion(.failure(error))
                return
            }

            do {
                let result = try JSONDecoder().decode(ImageQueryResult.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                print("❌ JSON decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

