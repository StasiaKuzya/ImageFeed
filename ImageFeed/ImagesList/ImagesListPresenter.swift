//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Анастасия on 21.12.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func fetchPhotos()
    func notifImagelistServiceObserver()
    func handleLikeButtonTap(for photo: Photo, at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    private var imagelistServiceObserver: NSObjectProtocol?
    private let imagesListService: ImagesListServiceProtocol
    weak var cellDelegate: ImagesListCellDelegate?

    init(view: ImagesListViewControllerProtocol? = nil, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func fetchPhotos() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func notifImagelistServiceObserver() {
        imagelistServiceObserver =
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                print("Received DidChangeNotification")
                self.view?.updateTableViewAnimated()
            }
    }
    
    func handleLikeButtonTap(for photo: Photo, at indexPath: IndexPath) {
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.view?.photos = self.imagesListService.photos
                self.view?.updateCell(at: indexPath)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.view?.showLikeErrorAlert()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
