//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 19.10.2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Constants
    
    private let profileImage = UIImageView()
    private let logOutButton = UIButton()
    private let userName = UILabel()
    private let userLogin = UILabel()
    private let userDescription = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        creationOfProfileImage()
        creationOfLogOutButton()
        creationOfUserName()
        creationOfUserLogin()
        creationOfUserDescription()
    }
    
    // MARK: - Private Methods
    
    private func creationOfProfileImage() {

        let imageForProfile = UIImage(named: "UserPic")
        profileImage.image = imageForProfile
        profileImage.layer.cornerRadius = 70 / 2
        
        view.addSubview(profileImage)
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        profileImage.heightAnchor.constraint(equalToConstant: 70)
        profileImage.widthAnchor.constraint(equalToConstant: 70)
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func creationOfLogOutButton() {

        logOutButton.setImage(UIImage(named: "Exit"), for: .normal)

        view.addSubview(logOutButton)
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        logOutButton.heightAnchor.constraint(equalToConstant: 44)
        logOutButton.widthAnchor.constraint(equalToConstant: 44)
        logOutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)

        NSLayoutConstraint.activate([
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }

    private func creationOfUserName() {

        userName.text = "Екатерина Новикова"
        userName.font = UIFont(name: "SF Pro", size: 23)
        userName.font = UIFont.boldSystemFont(ofSize: 23)
        userName.textColor = .ypWhite
        
        view.addSubview(userName)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        userName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8)
        userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }

    private func creationOfUserLogin() {

        userLogin.text = "@ekaterina_nov"
        userLogin.font = UIFont(name: "SF Pro", size: 13)
        userLogin.textColor = .ypGray
        
        view.addSubview(userLogin)
        
        userLogin.translatesAutoresizingMaskIntoConstraints = false
        
        userLogin.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8)
        userLogin.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            userLogin.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userLogin.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func creationOfUserDescription() {

        userDescription.text = "Hello, world!"
        userDescription.font = UIFont(name: "SF Pro", size: 13)
        userDescription.textColor = .ypWhite
        
        view.addSubview(userDescription)
        
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        
        userDescription.topAnchor.constraint(equalTo: userLogin.bottomAnchor, constant: 8)
        userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            userDescription.topAnchor.constraint(equalTo: userLogin.bottomAnchor, constant: 8),
            userDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
}
