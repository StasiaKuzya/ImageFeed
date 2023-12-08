//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 19.10.2023.
//

import Foundation
import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants & Properties
    
    private let profileImage = UIImageView()
    private let logOutButton = UIButton()
    private let userName = UILabel()
    private let userLogin = UILabel()
    private let userDescription = UILabel()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        creationOfProfileImage()
        creationOfLogOutButton()
        creationOfUserName()
        creationOfUserLogin()
        creationOfUserDescription()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private Methods
    
    private func creationOfProfileImage() {
        
        let imageForProfile = UIImage(named: "UserPic")
        profileImage.image = imageForProfile
        profileImage.layer.cornerRadius = 70 / 2
        
        view.addSubview(profileImage)
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func creationOfLogOutButton() {
        
        logOutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        
        view.addSubview(logOutButton)
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }
    
    private func creationOfUserName() {
        
        userName.text = "Name Surname"
        userName.font = UIFont(name: "SF Pro", size: 23)
        userName.font = UIFont.boldSystemFont(ofSize: 23)
        userName.textColor = .ypWhite
        
        view.addSubview(userName)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func creationOfUserLogin() {
        
        userLogin.text = "@test"
        userLogin.font = UIFont(name: "SF Pro", size: 13)
        userLogin.textColor = .ypGray
        
        view.addSubview(userLogin)
        
        userLogin.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userLogin.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userLogin.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func creationOfUserDescription() {
        
        userDescription.text = "test"
        userDescription.font = UIFont(name: "SF Pro", size: 13)
        userDescription.textColor = .ypWhite
        
        view.addSubview(userDescription)
        
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userDescription.topAnchor.constraint(equalTo: userLogin.bottomAnchor, constant: 8),
            userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    func updateProfileDetails(profile: ProfileData) {
        DispatchQueue.main.async { [weak self] in
            self?.userLogin.text = profile.userLogin
            self?.userName.text = profile.userName
            self?.userDescription.text = profile.userDescription
        }
        print("Updating UI with profile data")
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        let processor = RoundCornerImageProcessor(cornerRadius: 70/2, backgroundColor: .ypBlack)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "UserPickHolder"),
                                 options: [.processor(processor)])
    }
    
    @objc private func logOutButtonTapped() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти",
            primaryButton: AlertButton(
                buttonText: "Да",
                completion: {[weak self] in
                    self?.logOut()
                }
            ),
            additionalButtons: [AlertButton(
                buttonText: "Нет",
                completion: nil
            )]
        )
        
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }
    
    private func logOut() {
        // Очистите куки (пример для WKWebView)
        clean()
        
        // Очистите данные пользователя (удаляем токен)
        KeychainWrapper.standard.removeObject(forKey: "BearerToken")
        
        // Переход на SplashViewController после выхода
        let splashViewController = SplashViewController()
        splashViewController.modalPresentationStyle = .fullScreen
        present(splashViewController, animated: true)
    }
    
    private func clean() {
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
