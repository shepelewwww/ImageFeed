//
//  ImagesListServiceTests.swift
//  ImagesListServiceTests
//
//  Created by Артем Шепелев on 4.05.2026.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {

    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        
        let observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }
        
        service.fetchPhotosNextPage()
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        
        NotificationCenter.default.removeObserver(observer)
    }
}
