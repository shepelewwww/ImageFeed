//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Артем Шепелев on 4.05.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {

    static let shared = ProfileLogoutService()
    private init() {}

    func logout() {
        cleanCookies()
        resetServices()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {})
            }
        }
    }

    private func resetServices() {
        OAuth2TokenStorage.shared.token = nil

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
    }
}
