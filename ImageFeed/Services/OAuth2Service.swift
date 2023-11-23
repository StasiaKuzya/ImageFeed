//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Анастасия on 09.11.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {
        self.urlSession = URLSession.shared
    }
    
    private let urlSession: URLSession
    
    private var oauth2TokenStorage = OAuth2TokenStorage()
    private (set) var authToken: String? {
        get {
            return oauth2TokenStorage.token
        }
        set {
            oauth2TokenStorage.token = newValue
        }
    }
    private var lastCode: String?
    private var task: URLSessionTask?
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        print("OAuth Token Request: \(request)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self?.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
                self?.lastCode = nil
                self?.task = nil
            }
        }
            self.task = task
            task.resume()
        }
    }

extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
}
    // MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
    // MARK: - Network Connection

//enum NetworkError: Error {
//    case httpStatusCode(Int)
//    case urlRequestError(Error)
//    case urlSessionError
//}
