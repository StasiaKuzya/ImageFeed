//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Анастасия on 20.12.2023.
//

import Foundation
import XCTest
@testable import ImageFeed
import Kingfisher

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    private(set) var updateProfileDetailsCalled = false
    private(set) var updateAvatarCalled = false
    private(set) var switchToSplashViewControllerCalled = false
    private(set) var logOutCalled = false
    var updatedAvatarURL: URL?

    
    func updateProfileDetails(profile: ProfileData) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(with url: URL, placeholder: UIImage?, options: KingfisherOptionsInfo?) {
        updateAvatarCalled = true
        updatedAvatarURL = url
    }
    
    func switchToSplashViewController() {
        switchToSplashViewControllerCalled = true
    }
    
    func logOut() {
        logOutCalled = true
    }
}
