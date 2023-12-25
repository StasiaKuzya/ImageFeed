//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Анастасия on 22.11.2023.
//

import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    
    func setAvatarURL(_ url: String)
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?

    private init() {}
    
    func setAvatarURL(_ url: String) {
        avatarURL = url
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){

        guard let token = OAuth2TokenStorage().token else { return }
        
        let url = URL(string: "\(UnsplashAPI.defaultBaseURL)users/\(username)")!
        var request = URLRequest(url: url)

        // Устанавливаем заголовок Authorization с Bearer токеном
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    let smallImageURL = userResult.profileImage.small
                    completion(.success(smallImageURL))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
            task.resume()
        }
}
