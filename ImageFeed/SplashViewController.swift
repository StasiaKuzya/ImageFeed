//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 10.11.2023.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    private let launchScreenImage = UIImageView()
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegueId"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared


    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        creationOfSplashScreen()
        
        if let token = OAuth2TokenStorage().token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
// MARK: -  Private Methods

    private func creationOfSplashScreen() {

        let imageForlaunchScreen = UIImage(named: "LaunchScreen")
        launchScreenImage.image = imageForlaunchScreen
        view.backgroundColor = .ypBlack
        
        view.addSubview(launchScreenImage)
        
        launchScreenImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            launchScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            launchScreenImage.widthAnchor.constraint(equalToConstant: 75),
            launchScreenImage.heightAnchor.constraint(equalToConstant: 77.679)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

    // MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                print("Successfully fetched OAuth Token")
                self.fetchProfile(token: token)
            case .failure:
                print("Failed to fetch OAuth Token")
                self.showFetchErrorAlert()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfile(token: String) {
        
        profileService.fetchProfile(token) { result in
            switch result {
            case .success(let profileResult):
                
                let username = profileResult.userLogin
                self.profileImageService.fetchProfileImageURL(username: username) { imageResult in
                    switch imageResult {
                    case .success(let profileImageURL):
                        print("Successfully fetched profile image URL: \(profileImageURL)")
                        self.profileImageService.setAvatarURL(profileImageURL)
                        
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL]
                        )
                        
                    case .failure(let error):
                        print("Error fetching profile image URL: \(error)")
                    }
                }
                
                let profile = ProfileData(
                    userLogin: "@\(profileResult.userLogin)",
                    userName: "\(profileResult.firstName) \(profileResult.lastName)",
                    userDescription: profileResult.bio ?? "")
                self.profileService.setProfile(profile)
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching profile: \(error)")
                    print("Showing alert on profile screen...")
                    self.showFetchErrorAlert()
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func showFetchErrorAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            primaryButton: AlertButton(
                buttonText: "ОК",
                completion: { [weak self] in
                    // По закрытии алерта, проверяем наличие токена
                    guard let self = self, let token = OAuth2TokenStorage().token else {
                        return
                    }
                    // Если токен есть, тогда переходим к TabBarController
                    self.fetchProfile(token: token)
                    self.switchToTabBarController()
                }
            ),
            additionalButtons: nil
        )
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}
