//
//  ViewController.swift
//  AlamofireFeatureTest
//
//  Created by Manh Pham on 6/18/22.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        AppNetwork.default.request(route: AppRoute.login(username: "admin@admin.com", password: "pwd12345"), type: LoginResponse.self) { response in
            switch response {
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
        AppNetwork.default.request(route: AppRoute.getUserInfo, type: UserResponse.self) { response in
            switch response {
            case .success(let data):
                print("getUserInfo", data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func getList(_ sender: Any) {
        AppNetwork.default.request(route: AppRoute.getList(page: 1), type: ArrayPagingResponse.self) { response in
            switch response {
            case .success(let data):
                print("getList", data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func getUserInfoAndGetList(_ sender: Any) {
        AppNetwork.default.request(route: AppRoute.getUserInfo, type: UserResponse.self) { response in
            switch response {
            case .success(let data):
                print("getUserInfo", data)
            case .failure(let error):
                print(error)
            }
        }
        
        AppNetwork.default.request(route: AppRoute.getList(page: 1), type: ArrayPagingResponse.self) { response in
            switch response {
            case .success(let data):
                print("getList", data)
            case .failure(let error):
                print(error)
            }
        }
        
        AppNetwork.default.request(route: AppRoute.getUserInfo, type: UserResponse.self) { response in
            switch response {
            case .success(let data):
                print("getUserInfo", data)
            case .failure(let error):
                print(error)
            }
        }
        
        AppNetwork.default.request(route: AppRoute.getList(page: 1), type: ArrayPagingResponse.self) { response in
            switch response {
            case .success(let data):
                print("getList", data)
            case .failure(let error):
                print(error)
            }
        }
        
        AppNetwork.default.request(route: AppRoute.getUserInfo, type: UserResponse.self) { response in
            switch response {
            case .success(let data):
                print("getUserInfo", data)
            case .failure(let error):
                print(error)
            }
        }
        
        AppNetwork.default.request(route: AppRoute.getList(page: 1), type: ArrayPagingResponse.self) { response in
            switch response {
            case .success(let data):
                print("getList", data)
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

