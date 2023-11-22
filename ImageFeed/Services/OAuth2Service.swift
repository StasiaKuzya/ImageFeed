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
        
        let task = object(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self?.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))

                        self?.lastCode = nil
                }
                self?.task = nil
            }
        }
            
            //        let task = object(for: request) { [weak self] result in
            //            guard let self = self else { return }
            //            switch result {
            //            case .success(let body):
            //                let authToken = body.accessToken
            //                self.authToken = authToken
            //                completion(.success(authToken))
            //            case .failure(let error):
            //                completion(.failure(error))
            //            }
            //        }
            self.task = task
            task.resume()
        }
    }

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                return Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
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

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}