//
//  UserResult.swift
//  ImageFeed
//
//  Created by Анастасия on 22.11.2023.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}
