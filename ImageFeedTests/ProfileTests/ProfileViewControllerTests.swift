//
//  ProfileViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Анастасия on 19.12.2023.
//

import Foundation
import XCTest
@testable import ImageFeed
import Kingfisher

final class ProfileViewControllerTests: XCTestCase {
    
    func testUpdateProfileDetailsCallsPresenterMethod() {
        //Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        let mockProfileData = ProfileData(userLogin: "John Doe", userName: "john_doe", userDescription: "Test description")
        viewController.updateProfileDetails(profile: mockProfileData)
        
        //Then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
    }
    
    func testLogOutButtonTapped() {
        //Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.logOutButtonTapped()
        
        //Then
        XCTAssertTrue(viewController.switchToSplashViewControllerCalled)
    }
    
    func testUpdateAvatar() {
        //Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        let mockProfileImageService = MockProfileImageService()
        mockProfileImageService.setAvatarURL("https://example.com/mock-avatar.jpg")
        presenter.profileImageService = mockProfileImageService
        
        //When
        presenter.updateAvatar()
        
        //Then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.updatedAvatarURL, URL(string: "https://example.com/mock-avatar.jpg"))
    }
    
}
