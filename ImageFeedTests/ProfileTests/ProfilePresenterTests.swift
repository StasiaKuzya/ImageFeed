//
//  ProfilePresenterTests.swift
//  ImageFeedTests
//
//  Created by Анастасия on 19.12.2023.
//

import XCTest
import Foundation
@testable import ImageFeed
import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var tokenStorage: OAuth2TokenStorageProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var logOutButtonTappedCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logOutButtonTapped() {
        tokenStorage?.token = nil
    }
    
    func updateAvatar() {
    }
}

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
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        let tokenStorageMock = MockOAuth2TokenStorage()
        presenter.tokenStorage = tokenStorageMock

        // When
        tokenStorageMock.token = "smtg"
        presenter.logOutButtonTapped()

        // Then
        XCTAssertNil(tokenStorageMock.token)
    }
}
