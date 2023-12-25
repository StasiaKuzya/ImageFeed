//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Анастасия on 18.12.2023.
//

import Foundation
import Kingfisher
import UIKit
import SwiftKeychainWrapper
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileImageService: ProfileImageServiceProtocol? { get set }
    var tokenStorage: OAuth2TokenStorageProtocol? { get set }
    func viewDidLoad()
    func logOutButtonTapped()
    func updateAvatar()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    var profileImageService: ProfileImageServiceProtocol? = ProfileImageService.shared
    var tokenStorage: OAuth2TokenStorageProtocol?
    
    init(view: ProfileViewControllerProtocol? = nil) {
        self.view = view
    }
    
    func viewDidLoad() {
        observeAvatarChanges()
        updateAvatar()
    }
    
    func observeAvatarChanges(){
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService?.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 70/2, backgroundColor: .ypBlack)
        view?.updateAvatar(with: url, placeholder: UIImage(named: "UserPickHolder"), options: [.processor(processor)])
    }
    
    func updateProfileDetails(profile: ProfileData){
        view?.updateProfileDetails(profile: profile)
    }
    
    
    func logOutButtonTapped() {
        print("logOutButtonTapped called")
        clean()
        KeychainWrapper.standard.removeObject(forKey: "BearerToken")
        view?.switchToSplashViewController()
    }
    
    func clean() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
