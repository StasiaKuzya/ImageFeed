//
//  ProfilePresenterTests.swift
//  ImageFeedTests
//
//  Created by Анастасия on 19.12.2023.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ProfilePresenterTests: XCTestCase {

    func testProfileViewControllerCallsViewDidLoad() {
        //Given
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        
        //When
        _ = profileViewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testCleanTokenStorage() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        let tokenStorageMock = MockOAuth2TokenStorage()
        presenter.tokenStorage?.token = tokenStorageMock.token

        // When
        tokenStorageMock.token = "smtg"
        viewController.logOut()

        // Then
        XCTAssertNil(presenter.tokenStorage?.token)
    }
    
    func testLogOutCalled() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        viewController.logOut()

        // Then
        XCTAssertTrue(presenter.logOutButtonTappedCalled)
    }
}
