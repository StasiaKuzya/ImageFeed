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
            // Возвращаем предопределенный URL вместо реального запроса к сети
            completion(.success("https://example.com/mock-avatar.jpg"))
        } else {
            // Возвращаем ошибку, если необходимо симулировать неудачный запрос
            completion(.failure(MockError.mockError))
        }
    }
}

enum MockError: Error {
    case mockError
}
