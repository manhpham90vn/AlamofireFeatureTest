//
//  RefreshTokenInterceptor.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/19/22.
//

import Foundation
import Alamofire

class RefreshTokenInterceptor: RequestInterceptor {
    typealias RequestRetryCompletion = (RetryResult) -> Void
    private var lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // auto update token
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock {
            guard let response = request.response, response.statusCode == 401 else {
                completion(.doNotRetry)
                return
            }
                        
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                isRefreshing = true
                refreshToken { [weak self] result in
                    guard let self = self else { return }
                    self.lock.lock {
                        switch result {
                        case let .success(token):
                            UserDefaults.standard.set(token, forKey: "token")
                            self.requestsToRetry.forEach { $0(.retry) }
                            self.requestsToRetry.removeAll()
                        case let .failure(error):
                            self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                            self.requestsToRetry.removeAll()
                        }
                        self.isRefreshing = false
                    }
                }
            }
        }
    }
    
    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        AF.request("http://localhost.charlesproxy.com:3000/refreshToken",
                   method: .post,
                   parameters: ["token": UserDefaults.standard.value(forKey: "refreshToken") as? String ?? ""],
                   encoding: URLEncoding.httpBody)
            .responseDecodable(of: RefreshTokenResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data.token))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}
