//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Анастасия on 30.11.2023.
//

//import Foundation
//
//class ImagesListService {
//    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
//    static let shared = ImagesListService()
//    private (set) var photos: [Photo] = []
//
//    private(set) var lastLoadedPage: Int?
//    private(set) var isFetching = false
////    private var nextPage = 1
//
//    private init() {}
//
//    func fetchPhotosNextPage() {
//
////        var nextPage: Int
////        if let lastLoadedPage = lastLoadedPage {
////            nextPage = lastLoadedPage + 1
////        } else { nextPage = 1 }
//
//        guard !isFetching else { return }
//
//        isFetching = true
//
//        let baseURL = URL(string: "\(DefaultBaseURL)")!
//        let photosURL = baseURL.appendingPathComponent("photos")
//
//        var components = URLComponents(url: photosURL, resolvingAgainstBaseURL: true)
//        components?.queryItems = [
//            URLQueryItem(name: "page", value: "\(lastLoadedPage ?? 1)"),
//            URLQueryItem(name: "per_page", value: "10"),
//            URLQueryItem(name: "order_by", value: "latest"),
//            URLQueryItem(name: "client_id", value: AccessKey)
//        ]
//
//        guard let url = components?.url else {
////            isFetching = false
//            return}
//
//        let request = URLRequest(url: url)
//
//        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
//            guard let self = self else { return }
//
//            defer { self.isFetching = false }
//
//            switch result {
//            case .success(let photoResults):
//
////                print("Received photo results: \(photoResults)")
//
//                let newPhotos = photoResults.map { Photo(photoResult: $0) }
//                DispatchQueue.main.async {
//                    self.photos.append(contentsOf: newPhotos)
//                    // Увеличиваем номер следующей страницы для закачки.
////                    nextPage += 1
//                    self.lastLoadedPage = (self.lastLoadedPage ?? 1) + 1
//
//                    // Публикуем нотификацию об изменении данных.
//                    NotificationCenter.default.post(name: Self.DidChangeNotification, object: nil)
//                }
//            case .failure(let error):
//                // Обработка ошибки.
//                print("Error fetching photos: \(error)")
//            }
//        }
//        task.resume()
//    }
//}
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
