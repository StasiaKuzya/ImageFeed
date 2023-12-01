//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Анастасия on 30.11.2023.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
//    let user: UserResult
    let urls: UrlsResult

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
//        case user
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
