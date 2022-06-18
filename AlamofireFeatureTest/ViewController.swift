//
//  ViewController.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/18/22.
//

import UIKit
import Alamofire

class Logger: EventMonitor {
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
}

class XTypeAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(name: "X-Type", value: "iOS")
        completion(.success(urlRequest))
    }
}

// auto update token
class AuthenAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: UserDefaults.standard.value(forKey: "token") as? String ?? ""))
        completion(.success(urlRequest))
    }
}

struct SynchronizedSerial {
    private let mutex = DispatchQueue(label: "com.synchronized.serial")
    mutating func mutate<T>(_ block: () throws -> T) rethrows -> T {
        try mutex.sync {
            return try block()
        }
    }
}

class RefreshTokenInterceptor: RequestInterceptor {
    typealias RequestRetryCompletion = (RetryResult) -> Void
    private var lock = SynchronizedSerial()
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []

    // auto update token
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.mutate {
            guard let response = request.response, response.statusCode == 401 else {
                completion(.doNotRetry)
                return
            }
            
            guard request.retryCount < 3 else {
                completion(.doNotRetry)
                return
            }
            
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                isRefreshing = true
                AF.request("http://localhost.charlesproxy.com:3000/refreshToken",
                           method: .post,
                           parameters: ["token": UserDefaults.standard.value(forKey: "refreshToken") as? String ?? ""],
                           encoding: URLEncoding.httpBody)
                    .responseDecodable(of: RefreshTokenResponse.self) { [weak self] response in
                        guard let self = self else { return }
                        self.isRefreshing = false
                        switch response.result {
                        case .success(let data):
                            UserDefaults.standard.set(data.token, forKey: "token")
                            self.requestsToRetry.forEach { $0(.retry) }
                            self.requestsToRetry.removeAll()
                        case .failure(let error):
                            self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                            self.requestsToRetry.removeAll()
                        }
                    }
            }
        }
    }
}

class ViewController: UIViewController, AlamofireExtended {

    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateSession()
    }

    func updateSession() {
        // config
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 3
        
        // Interceptor
        let composite = Interceptor(adapters: [XTypeAdapter(), AuthenAdapter()], interceptors: [RefreshTokenInterceptor()])
        
        let session = Session(interceptor: composite, eventMonitors: [Logger()])
        self.session = session
    }
    
    @IBAction func login(_ sender: Any) {
        session.request("http://localhost.charlesproxy.com:3000/login",
                        method: .post,
                        parameters: ["email": "admin@admin.com", "password": "pwd12345"],
                        encoding: URLEncoding.httpBody)
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("login", data)
                    UserDefaults.standard.set(data.token, forKey: "token")
                    UserDefaults.standard.set(data.refreshToken, forKey: "refreshToken")
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @IBAction func getUserInfo(_ sender: Any) {
        session.request("http://localhost.charlesproxy.com:3000/user")
            .responseDecodable(of: UserResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @IBAction func getList(_ sender: Any) {
        session.request("http://localhost.charlesproxy.com:3000/paging",
                        parameters: ["page": 1],
                        encoding: URLEncoding.queryString)
            .responseDecodable(of: ArrayPagingResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @IBAction func getUserInfoAndGetList(_ sender: Any) {
        session.request("http://localhost.charlesproxy.com:3000/user")
            .responseDecodable(of: UserResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
        
        session.request("http://localhost.charlesproxy.com:3000/user")
            .responseDecodable(of: UserResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
        
        session.request("http://localhost.charlesproxy.com:3000/user")
            .responseDecodable(of: UserResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
        
        session.request("http://localhost.charlesproxy.com:3000/paging",
                        parameters: ["page": 1],
                        encoding: URLEncoding.queryString)
            .responseDecodable(of: ArrayPagingResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
        
        session.request("http://localhost.charlesproxy.com:3000/paging",
                        parameters: ["page": 1],
                        encoding: URLEncoding.queryString)
            .responseDecodable(of: ArrayPagingResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
        
        session.request("http://localhost.charlesproxy.com:3000/paging",
                        parameters: ["page": 1],
                        encoding: URLEncoding.queryString)
            .responseDecodable(of: ArrayPagingResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("getUserInfo", data)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @IBAction func cleanLocalData(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        print("token", UserDefaults.standard.value(forKey: "token") ?? "null")
        print("refreshToken", UserDefaults.standard.value(forKey: "refreshToken") ?? "null")
    }
        
}

