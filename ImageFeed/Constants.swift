//
//  Constants.swift
//  ImageFeed
//
//  Created by Анастасия on 03.11.2023.
//

import Foundation

enum UnsplashAPI {
    static let accessKey = "yx1VixtKssIo8o_V23NldiqoJouoFA8--BYrkeTZdaA"
    static let secretKey = "YzU77Q15Cx0J_wr89e7XcNyk3ATjFscPtVsBrQZSjhY"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURL: URL,
        authURLString: String) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.redirectURI = redirectURI
            self.accessScope = accessScope
            self.defaultBaseURL = defaultBaseURL
            self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: UnsplashAPI.accessKey,
            secretKey: UnsplashAPI.secretKey,
            redirectURI: UnsplashAPI.redirectURI,
            accessScope: UnsplashAPI.accessScope,
            defaultBaseURL: UnsplashAPI.defaultBaseURL,
            authURLString: UnsplashAPI.unsplashAuthorizeURLString)
    }
}
