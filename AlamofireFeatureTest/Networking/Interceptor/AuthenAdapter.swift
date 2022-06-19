//
//  AuthenAdapter.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/19/22.
//

import Foundation
import Alamofire

// auto update token
// todo: add protocol to add token if need
class AuthenAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: UserDefaults.standard.value(forKey: "token") as? String ?? ""))
        completion(.success(urlRequest))
    }
}
