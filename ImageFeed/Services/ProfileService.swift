//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Анастасия on 19.11.2023.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        
        guard let token = OAuth2TokenStorage().token else { return }
        
        let url = URL(string: "\(DefaultBaseURL)me")!
        var request = URLRequest(url: url)
        
        // Устанавливаем заголовок Authorization с Bearer токеном
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                // Обработка ошибки, если статус код не в диапазоне 200-299
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "HTTP", code: statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            // Разбор данных ответа в модель ProfileResult
            if let data = data {
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    completion(.success(profileResult))
                } catch {
                    completion(.failure(error))
                }
            } else {
                // Обработка сценария, когда данные отсутствуют
                completion(.failure(NSError(domain: "Data", code: -1, userInfo: nil)))
            }
        }
        
        task.resume()
    }
}
