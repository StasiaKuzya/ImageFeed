//
//  ProfileViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Анастасия on 19.12.2023.
//

import Foundation
import XCTest
@testable import ImageFeed
import Foundation
import ImageFeed
import Kingfisher

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    private(set) var updateProfileDetailsCalled = false
    private(set) var updateAvatarCalled = false
    private(set) var switchToSplashViewControllerCalled = false
    
    func updateProfileDetails(profile: ProfileData) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(with url: URL, placeholder: UIImage?, options: KingfisherOptionsInfo?) {
        updateAvatarCalled = true
    }
    
    func switchToSplashViewController() {
        switchToSplashViewControllerCalled = true
    }
}

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

}
