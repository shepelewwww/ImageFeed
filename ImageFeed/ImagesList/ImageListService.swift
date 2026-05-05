//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Артем Шепелев on 4.05.2026.
//

import Foundation
import CoreGraphics

final class ImagesListService {

    // MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}

    // MARK: - Public
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    // MARK: - Private
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private var lastLoadedPage: Int?
    private var isLoading = false

    private let dateFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()

    // MARK: - Fetch next page
    func fetchPhotosNextPage() {

        guard !isLoading else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Нет токена")
            return
        }

        guard let request = makeRequest(page: nextPage, token: token) else {
            print("[ImagesListService]: Невалидный request")
            return
        }

        isLoading = true

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            self.isLoading = false

            switch result {
            case .success(let results):
                let newPhotos = results.map { self.convert($0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }

            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: Ошибка - \(error)")
            }
        }

        task?.resume()
    }

    // MARK: - Helpers
    
    func reset() {
        photos = []
        lastLoadedPage = nil
        isLoading = false
        task?.cancel()
        task = nil
    }

    private func makeRequest(page: Int, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/photos?page=\(page)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    private func convert(_ result: PhotoResult) -> Photo {
        let date = result.createdAt.flatMap { dateFormatter.date(from: $0) }

        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: date,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.regular,
            fullImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    // MARK: - Like
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, _, error in
            
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked
                    )
                    
                    self.photos[index] = newPhoto
                }
                
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
}
