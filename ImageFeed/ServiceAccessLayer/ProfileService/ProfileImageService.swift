import Foundation

// MARK: - Models

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImageService

final class ProfileImageService {
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Notifications
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private var task: URLSessionTask?
    
    // MARK: - Public Properties
    private(set) var avatarURL: String?
    
    // MARK: - Fetch Avatar
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"]
            )
            print("[ProfileImageService.fetchProfileImageURL]: Ошибка - \(error)")
            completion(.failure(error))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            let error = URLError(.badURL)
            print("[ProfileImageService.fetchProfileImageURL]: Ошибка - \(error)")
            completion(.failure(error))
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.small
                print("[ProfileImageService.fetchProfileImageURL]: Успешно получили URL аватарки - \(self.avatarURL ?? "")")
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
                completion(.success(userResult.profileImage.small))
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Ошибка - \(error)")
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Create URLRequest
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
