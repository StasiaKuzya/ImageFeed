//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 10.11.2023.
//

import Foundation
import UIKit
import ProgressHUD

class SplashViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegueId"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared


    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage().token {
            fetchProfile(token: token)
//            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
//    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
//                 //TODO [Sprint 11]
                self.showFetchErrorAlert()
                UIBlockingProgressHUD.dismiss()
            //break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        
        profileService.fetchProfile(token) { result in
            switch result {
            case .success(let profileResult):
                
                let username = profileResult.userLogin
                ProfileImageService.shared.fetchProfileImageURL(username: username) { imageResult in
                    switch imageResult {
                    case .success(let profileImageURL):
                        print("Successfully fetched profile image URL: \(profileImageURL)")
//                        self.profileImageService.avatarURL = profileImageURL
                        self.profileImageService.setAvatarURL(profileImageURL)
                        
                        NotificationCenter.default.post(
                            name: ProfileImageService.DidChangeNotification,
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
                    // TODO: Показать ошибку загрузки профиля
                    
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
        )
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        
        print("Switched to TabBarController")
    }
}
