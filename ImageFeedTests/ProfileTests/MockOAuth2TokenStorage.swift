//
//  MockOAuth2TokenStorage.swift
//  ImageFeedTests
//
//  Created by Анастасия on 19.12.2023.
//

import Foundation
@testable import ImageFeed

class MockOAuth2TokenStorage: OAuth2TokenStorageProtocol {
    var token: String?
}
