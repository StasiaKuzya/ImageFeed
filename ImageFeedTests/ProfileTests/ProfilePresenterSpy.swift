//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Анастасия on 20.12.2023.
//
import XCTest
import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var profileImageService: ProfileImageServiceProtocol?
    var tokenStorage: OAuth2TokenStorageProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var logOutButtonTappedCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logOutButtonTapped() {
        logOutButtonTappedCalled = true
    }
    
    func updateAvatar() {
    }
}
