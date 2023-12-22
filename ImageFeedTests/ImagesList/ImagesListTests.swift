//
//  ImagesListPresenterTests.swift
//  ImageFeedTests
//
//  Created by Анастасия on 22.12.2023.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testFetchPhotosCalled() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
    
    func testFetchImagesListPhoto() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let mockImageListService = MockImagesListService()
        let presenter = ImagesListPresenter(view: viewController, imagesListService: mockImageListService)
        viewController.presenter = presenter
        
        //When
        presenter.fetchPhotos()
        
        //Then
        XCTAssertTrue(mockImageListService.photos.count == 1)
        XCTAssertTrue(mockImageListService.photos[0].largeImageURL == "mockLargeURL")
        XCTAssertFalse(mockImageListService.isFetching)
    }
    
    func testFetchImagesListLikeChage() {
        //Given
        let mockImageListService = MockImagesListService()
        let presenter = ImagesListPresenter(view: nil, imagesListService: mockImageListService)

        //When
        presenter.fetchPhotos()
        
        let mockPhoto = mockImageListService.photos[0]
        let mockIndexPath = IndexPath(row: 0, section: 0)
        
        presenter.handleLikeButtonTap(for: mockPhoto, at: mockIndexPath)
        
        //Then
        XCTAssertTrue(mockImageListService.photos.count == 1)
        XCTAssertTrue(mockImageListService.photos[0].isLiked)
    }
    
    func testNotifImagelistServiceObserverCalled() {
        //Given
        let mockImageListService = MockImagesListService()
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(view: viewController, imagesListService: mockImageListService)
        
        //When
        presenter.notifImagelistServiceObserver()
        NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: nil)

        //Then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    func testUpdatedCell() {
        //Given
        let viewController = ImagesListViewControllerSpy()
        let mockImageListService = MockImagesListService()
        let presenter = ImagesListPresenter(view: viewController, imagesListService: mockImageListService)

        //When
        presenter.fetchPhotos()
        
        let mockPhoto = mockImageListService.photos[0]
        let mockIndexPath = IndexPath(row: 0, section: 0)
        
        presenter.handleLikeButtonTap(for: mockPhoto, at: mockIndexPath)
        
        //Then
        XCTAssertTrue(viewController.updateCellCalled)
    }
}
