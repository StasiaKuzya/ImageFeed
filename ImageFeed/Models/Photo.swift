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
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    // Инициализатор для создания объекта Photo из PhotoResult
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        
        if let createdAtString = photoResult.createdAt {
            createdAt = dateFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }

        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.full
        isLiked = photoResult.likedByUser
    }
}
