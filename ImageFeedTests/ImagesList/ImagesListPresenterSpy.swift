//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Анастасия on 22.12.2023.
//

import Foundation
import XCTest
@testable import ImageFeed

class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var fetchPhotosCalled = false
    var handleLikeButtonTapCalled = false
    var notifImagelistServiceObserverCalled = false
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func notifImagelistServiceObserver() {
        notifImagelistServiceObserverCalled = false
    }
    
    func handleLikeButtonTap(for photo: Photo, at indexPath: IndexPath) {
        handleLikeButtonTapCalled = true
    }
}

