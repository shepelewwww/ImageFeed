import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(""))
    }
}
