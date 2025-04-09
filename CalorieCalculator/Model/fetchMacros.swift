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
        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/FindMacro") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = "userId=\(userId)&entryDate=\(entryDate)"
        print("Fetch request parameters: \(parameters)")
        request.httpBody = parameters.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.fetchSuccess = false
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
            }

            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
            }

            guard let data = data else {
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
                DispatchQueue.main.async {
                    self.macros = macroResponses
                    self.fetchSuccess = true
                    self.errorMessage = nil
                    completion(.success(macroResponses))
                }
            } catch {
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
        guard let url = URL(string: "http://macrotracker.duckdns.org:8080/CalorieCalculator-1.0-SNAPSHOT/LogMacro") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "userId": userId,
            "entryDate": entryDate,
            "mealType": mealType,
            "calories": calories,
            "carbs": carbs,
            "protein": protein,
            "fat": fat
        ]

        let parameterString = formURLEncodedString(from: parameters)
        request.httpBody = parameterString.data(using: .utf8)

        let maxRetryAttempts = 1
        var retryCount = 0

        func executeRequest() {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    if retryCount < maxRetryAttempts {
                        retryCount += 1
                        print("Retrying... (\(retryCount))")
                        executeRequest()
                        return
                    }
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.addSuccess = false
                        completion(.failure(error))
                    }
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Add HTTP Status Code: \(httpResponse.statusCode)")
                }

                guard let data = data else {
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
                        let rawResponse = String(data: data, encoding: .utf8) ?? "No response body"
                        print("Unexpected response format: \(rawResponse)")
                        throw NSError(domain: "Parse Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
                    }
                } catch {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "No response body"
                    print("Add decoding error: \(error), Response: \(rawResponse)")
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse server response: \(error.localizedDescription)"
                        self.addSuccess = false
                        completion(.failure(error))
                    }
                }
            }.resume()
        }

        executeRequest()
    }

    private func formURLEncodedString(from parameters: [String: Any]) -> String {
        parameters.map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }.joined(separator: "&")
    }
}
