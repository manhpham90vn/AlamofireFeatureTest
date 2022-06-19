//
//  Response.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/19/22.
//

import Foundation
import Alamofire

struct LoginResponse: Decodable {
    var token: String
    var refreshToken: String
}

struct RefreshTokenResponse: Decodable {
    var token: String
}


struct UserResponse: Decodable {
    var email: String
    var name: String
}

struct PagingResponse: Decodable {
    var name: String
    var age: Int
}

struct ArrayPagingResponse: Decodable {
    var array: [PagingResponse]
}
