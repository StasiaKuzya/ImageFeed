//
//  Photo.swift
//  ImageFeed
//
//  Created by Анастасия on 30.11.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    var welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension Photo {
    
    private static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    // Инициализатор для создания объекта Photo из PhotoResult
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        
        if let resultCreatedAtString = photoResult.createdAt {
            createdAt = Self.isoDateFormatter.date(from: resultCreatedAtString)
        } else {
            createdAt = nil
        }

        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.full
        isLiked = photoResult.likedByUser
    }
}
