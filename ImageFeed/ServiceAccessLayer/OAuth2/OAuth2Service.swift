import Foundation

// MARK: - Auth Service Error

enum AuthServiceError: Error {
    case invalidRequest
}

// MARK: - OAuth2Service

final class OAuth2Service {
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    
    // MARK: - Dependencies
    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    // MARK: - Private Properties
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Properties
    private(set) var authToken: String? {
        get { return dataStorage.token }
        set { dataStorage.token = newValue }
    }
    
    // MARK: - Init
    private init() { }
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let body):
                self.authToken = body.accessToken
                print("[OAuth2Service.fetchOAuthToken]: Успешно получили токен")
                completion(.success(body.accessToken))
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: Ошибка - \(error)")
                completion(.failure(error))
            }
            self.lastCode = nil
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Models
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
