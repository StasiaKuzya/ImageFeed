//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Анастасия on 23.11.2023.
//

import Foundation

extension URLSession {
    
    private enum CustomError: Error {
        case invalidResponse
        case httpStatusCode
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(CustomError.invalidResponse))
                    return
                }
                
                if 200 ..< 300 ~= httpResponse.statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(T.self, from: data ?? Data())
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(CustomError.httpStatusCode))
                }
            }
        })
        
        return task
    }
}
