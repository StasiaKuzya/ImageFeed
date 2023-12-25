//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Анастасия on 09.11.2023.
//

import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "BearerToken")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "BearerToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "BearerToken")
            }
        }
    }
}
