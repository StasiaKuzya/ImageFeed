//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Анастасия on 09.11.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = authTokenRequest(code: code)
        print("OAuth Token Request: \(request)")

        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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



//import Foundation
//
//class OAuth2Service {
//
//    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
//
//        let url = URL(string: "https://unsplash.com/oauth/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let parameters: [String: String] = [
//            "client_id": AccessKey,
//            "client_secret": SecretKey,
//            "redirect_uri": RedirectURI,
//            "code": code,
//            "grant_type": "authorization_code"
//        ]
//
//        request.httpBody = parameters.percentEncoded()
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.invalidResponse))
//                }
//                return
//            }
//
//            if 200...299 ~= httpResponse.statusCode {
//                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
//                    do {
//                        let oauthResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: Data(jsonString.utf8))
//                        let accessToken = oauthResponse.accessToken
//                        DispatchQueue.main.async {
//                            completion(.success(accessToken))
//                        }
//                    } catch {
//                        DispatchQueue.main.async {
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.invalidStatusCode(httpResponse.statusCode)))
//                }
//            }
//        }
//
//        task.resume()
//    }
//}
//
//enum NetworkError: Error {
//    case invalidResponse
//    case invalidStatusCode(Int)
//}
//
//extension Dictionary where Key == String, Value == String {
//    func percentEncoded() -> Data? {
//        let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
//
//        return map { key, value in
//            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
//            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
//            return escapedKey + "=" + escapedValue
//        }
//        .joined(separator: "&")
//        .data(using: .utf8)
//    }
//}
