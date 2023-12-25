//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Анастасия on 19.11.2023.
//

import Foundation

protocol ProfileServiceProtocol {
    var profile: ProfileData? { get }
    
    func setProfile(_ newProfile: ProfileData)
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    
    static let shared = ProfileService()
    private(set) var profile: ProfileData?
    
    private init() {}
    
    func setProfile(_ newProfile: ProfileData) {
         profile = newProfile
     }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        
        guard let token = OAuth2TokenStorage().token else { return }
        
        let url = URL(string: "\(UnsplashAPI.defaultBaseURL)me")!
        var request = URLRequest(url: url)
        
        // Устанавливаем заголовок Authorization с Bearer токеном
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    completion(.success(profileResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
