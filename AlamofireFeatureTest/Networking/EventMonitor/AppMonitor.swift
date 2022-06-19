//
//  AppMonitor.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/19/22.
//

import Foundation
import Alamofire

class AppMonitor: EventMonitor {
    
    let queue: DispatchQueue = DispatchQueue(label: "com.manhpham.networklogger")
    
    func requestDidResume(_ request: Request) {
        print("requestDidResume", Date(), request.id)
    }
    
    func requestDidFinish(_ request: Request) {
        print("requestDidFinish", Date(), request.id)
    }
    
    func requestDidCancel(_ request: Request) {
        print("requestDidCancel", Date(), request.id)
    }
    
    func requestDidSuspend(_ request: Request) {
        print("requestDidSuspend", Date(), request.id)
    }
    
    func requestIsRetrying(_ request: Request) {
        print("requestIsRetrying", Date(), request.id)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        if let value = response.value {
            print("didParseResponse", Date(), request.id, value)
        }
    }
}
