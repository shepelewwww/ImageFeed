import Foundation


struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            let error = NSError(domain: "Invalid URL", code: -1)
            print("❌ [OAuth2Service] Invalid URL: \(error)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        guard let httpBody = parameters
            .map({ "\($0.key)=\($0.value)" })
            .joined(separator: "&")
            .data(using: .utf8) else {
            let error = NSError(domain: "Invalid HTTP body", code: -2)
            print("❌ [OAuth2Service] Failed to encode parameters: \(error)")
            completion(.failure(error))
            return
        }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {

                if let error = error {
                    print("❌ [OAuth2Service] Network error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "Invalid response", code: -3)
                    print("❌ [OAuth2Service] Invalid HTTP response: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode)
                    print("❌ [OAuth2Service] Unsplash API returned status code \(httpResponse.statusCode)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "No data", code: -4)
                    print("❌ [OAuth2Service] No data received: \(error)")
                    completion(.failure(error))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    
                    OAuth2TokenStorage.shared.token = decoded.accessToken
                    
                    completion(.success(decoded.accessToken))
                } catch {
                    print("❌ [OAuth2Service] Failed to decode OAuthTokenResponseBody: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
