//
//  Constants.swift
//  ImageFeed
//
//  Created by Анастасия on 03.11.2023.
//

import Foundation

let AccessKey = "yx1VixtKssIo8o_V23NldiqoJouoFA8--BYrkeTZdaA"
let SecretKey = "YzU77Q15Cx0J_wr89e7XcNyk3ATjFscPtVsBrQZSjhY"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
//let DefaultBaseURL: URL? = URL(string: "https://api.unsplash.com/")
let DefaultBaseURL = URL(string: "https://api.unsplash.com/")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseURL: DefaultBaseURL,
            authURLString: UnsplashAuthorizeURLString)
    }
}
