//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Анастасия on 09.11.2023.
//

import Foundation

class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "BearerToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BearerToken")
        }
    }
}
