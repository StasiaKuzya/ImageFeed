//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Анастасия on 30.11.2023.
//

import Foundation

class ImagesListService {
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private(set) var lastLoadedPage: Int?
    private(set) var isFetching = false
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        
        isFetching = true
        
        let baseURL = URL(string: "\(DefaultBaseURL)")!
        let photosURL = baseURL.appendingPathComponent("photos")
        
        var components = URLComponents(url: photosURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(lastLoadedPage ?? 1)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "order_by", value: "latest"),
            URLQueryItem(name: "client_id", value: AccessKey)
        ]
        
        guard let url = components?.url else {
            isFetching = false
            return
        }
        
        let request = URLRequest(url: url)
        
        // Отменяем предыдущий запрос, если таковой был
        task?.cancel()
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            defer {
                // Сбрасываем ссылку на задачу после её завершения
                self.task = nil
                self.isFetching = false
            }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(photoResult: $0) }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = (self.lastLoadedPage ?? 1) + 1
                    NotificationCenter.default.post(name: Self.DidChangeNotification, object: nil)
                }
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
        task?.resume()
    }
}
 
    // MARK: - POST & DELETE likes
    
extension ImagesListService {
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let baseURL = URL(string: "\(DefaultBaseURL)")!
        let likeURL = baseURL.appendingPathComponent("photos/\(photoId)/like")
        
        var request = URLRequest(url: likeURL)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                             id: photo.id,
                             size: photo.size,
                             createdAt: photo.createdAt,
                             welcomeDescription: photo.welcomeDescription,
                             thumbImageURL: photo.thumbImageURL,
                             largeImageURL: photo.largeImageURL,
                             isLiked: !photo.isLiked
                         )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    completion(.success(()))
                    NotificationCenter.default.post(name: Self.DidChangeNotification, object: nil)
                } else {
                    completion(.failure(NSError(domain: "ImagesListService", code: 404, userInfo: nil)))
                }
            }
        }
        task.resume()
    }
}

extension Array {
    func withReplaced(itemAt index: Index, newValue: Element) -> Array {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
