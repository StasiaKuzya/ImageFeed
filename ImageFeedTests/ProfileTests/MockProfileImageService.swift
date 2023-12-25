//
//  MockProfileImageService.swift
//  ImageFeedTests
//
//  Created by Анастасия on 20.12.2023.
//

import Foundation
@testable import ImageFeed

class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    var shouldFetchProfileImageURLSucceed = true

    func setAvatarURL(_ url: String) {
        avatarURL = url
    }

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if shouldFetchProfileImageURLSucceed {
            completion(.success("https://example.com/mock-avatar.jpg"))
        } else {
            completion(.failure(MockError.mockError))
        }
    }
}

enum MockError: Error {
    case mockError
}
