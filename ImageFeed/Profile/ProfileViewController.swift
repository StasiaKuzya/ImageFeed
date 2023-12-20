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

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: ProfileData)
    func switchToSplashViewController()
    func updateAvatar(with url: URL, placeholder: UIImage?, options: KingfisherOptionsInfo?)
    func logOut()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Constants & Properties
    
    private let profileImage = UIImageView()
    private let logOutButton = UIButton()
    private let userName = UILabel()
    private let userLogin = UILabel()
    private let userDescription = UILabel()
    
    let profileService = ProfileService.shared
    var presenter: ProfilePresenterProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        presenter = ProfilePresenter(view: self)
    }
    
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
        
        presenter?.viewDidLoad()
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
    
    @objc private func logOutButtonTapped() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти",
            primaryButton: AlertButton(
                buttonText: "Да",
                completion: { [weak self] in
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
    
    // MARK: - Methods
    
    func updateProfileDetails(profile: ProfileData) {
        DispatchQueue.main.async { [weak self] in
            self?.userLogin.text = profile.userLogin
            self?.userName.text = profile.userName
            self?.userDescription.text = profile.userDescription
        }
        print("Updating UI with profile data")
    }
    
    func updateAvatar(with url: URL, placeholder: UIImage?, options: KingfisherOptionsInfo?) {
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url, placeholder: placeholder, options: options)
    }
    
    func logOut() {
        presenter?.logOutButtonTapped()
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        
        print("Switched to SplashViewController")
    }
}
