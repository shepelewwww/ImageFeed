import Foundation

// MARK: - Models

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

// MARK: - ProfileService

final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Properties
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    var profile: Profile?
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: profileResult.username,
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: Ошибка - \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

