//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Артем Шепелев on 4.05.2026.
//

import Foundation

// MARK: - PhotoResult (ответ API)
struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

// MARK: - Urls
struct UrlsResult: Codable {
    let thumb: String
    let full: String
    let regular: String
}
