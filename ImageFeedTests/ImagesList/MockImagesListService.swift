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
        // Ваша реализация для загрузки мок-фото
        let mockPhoto = Photo(id: "1",
                              size: CGSize(width: 100, height: 100),
                              createdAt: Date(),
                              thumbImageURL: "mockThumbURL",
                              largeImageURL: "mockLargeURL",
                              isLiked: false)
        
        // Здесь вы можете добавить мок-фото в массив
        photos.append(mockPhoto)
        
        // Установите флаг, что данные загружены
        lastLoadedPage = 1
        isFetching = false
        
        // Симулируем отправку нотификации
        NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: nil)
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        // Симулируем изменение состояния лайка
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLike
        }
        completion(.success(()))
    }
}

