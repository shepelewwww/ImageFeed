import Foundation

// MARK: - Network Error

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
}

// MARK: - URLSession Extension

extension URLSession {
    
    // MARK: - Data Task
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if 200 ..< 300 ~= httpResponse.statusCode {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    print("[dataTask]: HTTP ошибка - код \(httpResponse.statusCode)")
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            } else if let error = error {
                print("[dataTask]: Ошибка запроса - \(error.localizedDescription)")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[dataTask]: Неизвестная ошибка URLSession")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Object Task (Generic)
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print("[objectTask]: Ошибка декодирования - \(error.localizedDescription), данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[objectTask]: Ошибка сети - \(error)")
                completion(.failure(error))
            }
        }
        
        return task
    }
}
