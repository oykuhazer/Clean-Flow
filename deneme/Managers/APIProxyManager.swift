

import Foundation

final class APIProxyManager {
    static let shared = APIProxyManager()
    
  
    private let baseURL = ""
    
    private init() {}
    
  
    func generateContent(
        prompt: String,
        creationType: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Jailbreak kontrolü
        if SecurityUtils.isJailbroken() {
            completion(.failure(NSError(
                domain: "APIProxy",
                code: -100,
                userInfo: [NSLocalizedDescriptionKey: "Service unavailable on modified devices."]
            )))
            return
        }
        
        let endpoint = "\(baseURL)/generateContent"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(
                domain: "APIProxy",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid endpoint URL"]
            )))
            return
        }
        
       
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "creationType": creationType
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "APIProxy",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
                )))
                return
            }
            
        
            if httpResponse.statusCode == 429 {
                completion(.failure(NSError(
                    domain: "APIProxy",
                    code: 429,
                    userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded. Please try again later."]
                )))
                return
            }
            
            guard httpResponse.statusCode == 200, let data = data else {
                completion(.failure(NSError(
                    domain: "APIProxy",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Request failed with status \(httpResponse.statusCode)"]
                )))
                return
            }
            
     
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? String {
                    completion(.success(content))
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = json["error"] as? String {
                    completion(.failure(NSError(
                        domain: "APIProxy",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: error]
                    )))
                } else {
                    completion(.failure(NSError(
                        domain: "APIProxy",
                        code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
