//
//  MockImagesListService.swift
//  ImageFeedTests
//
//  Created by Анастасия on 22.12.2023.
//

import Foundation
@testable import ImageFeed
import UIKit

class MockImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    var lastLoadedPage: Int? = nil
    var isFetching: Bool = false

    func fetchPhotosNextPage() {
        let mockPhoto = Photo(id: "1",
                              size: CGSize(width: 100, height: 100),
                              createdAt: Date(),
                              thumbImageURL: "mockThumbURL",
                              largeImageURL: "mockLargeURL",
                              isLiked: false)
        
        photos.append(mockPhoto)
        
        lastLoadedPage = 1
        isFetching = false
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLike
        }
        completion(.success(()))
    }
}

