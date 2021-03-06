//
//  AppNetwork.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/19/22.
//

import Foundation
import Alamofire

class AppNetwork {
    static let `default` = AppNetwork()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 3
        
        // Adapter
        let xTypeAdapter = XTypeAdapter()
        let authenAdapter = AuthenAdapter()
        
        // Interceptors
        let refreshTokenInterceptor = RefreshTokenInterceptor()
        let retryPolicy = RetryPolicy(retryLimit: 3, retryableHTTPMethods: [.get], retryableHTTPStatusCodes: [])
        
        // Event Monitors
        var eventMonitors: [EventMonitor] = []
        #if DEBUG
        let logger = AppMonitor()
        eventMonitors.append(logger)
        #endif
        
        // Interceptor
        let compositeInterceptor = Interceptor(adapters: [xTypeAdapter, authenAdapter],
                                    interceptors: [refreshTokenInterceptor, retryPolicy])
        let session = Session(interceptor: compositeInterceptor, eventMonitors: eventMonitors)
        self.session = session
    }
    
    private let session: Session!
    
    func cancelAllRequests() {
        session.cancelAllRequests()
    }
    
    // TODO: check if use validate() funtion lead call refresh token 2 time
    func request<T: Decodable>(route: URLRequestConvertible, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        session
            .request(route)
            .cURLDescription(calling: { curl in
                print(curl)
            })
            .responseDecodable(of: T.self) { response in
            switch response.result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
