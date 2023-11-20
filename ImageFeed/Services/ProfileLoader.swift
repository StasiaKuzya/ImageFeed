//
//  ProfileLoader.swift
//  ImageFeed
//
//  Created by Анастасия on 20.11.2023.
//

import Foundation

protocol ProfileLoaderProtocol{
    func loadProfile1()
}

protocol ProfileServiceDelegate: AnyObject {
    func show(model: ProfileData)
    func convert(model: ProfileResult) -> ProfileData
}

struct ProfileLoader: ProfileLoaderProtocol {
    
    private let profileService: ProfileServiceProtocol?
    private weak var delegate: ProfileServiceDelegate?
    
    init(profileService: ProfileServiceProtocol = ProfileService(), delegate: ProfileServiceDelegate) {
        self.profileService = profileService
        self.delegate = delegate
    }
    
     func loadProfile1() {
        profileService?.fetchProfile("") { result in
            switch result {
            case .success(let profileResult):
                let profileData = self.delegate?.convert(model: profileResult)
                DispatchQueue.main.async {
                    guard let profileData = profileData else { return }
                    self.delegate?.show(model: profileData)
                }
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }
}
