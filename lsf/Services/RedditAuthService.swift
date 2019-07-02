//
//  RedditAuth.swift
//  lsf
//
//  Created by Mitchell Gerber on 5/29/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Alamofire

class RedditAuthService {
    
    // non user based oauth
    let userAgent: String
    private let non_user_client_id = "Y2NoNa4zUyLbCA"
    private let non_user_oauth_url = "https://www.reddit.com/api/v1/access_token"
    lazy var oauthClient: SessionManager = {
        let client = SessionManager()
        let redditInterceptor = RedditInterceptorService(userAgent: self.userAgent, handlerFunc: self.setupNonUserOauthHandler)
        redditInterceptor.redditAuthentication = StorageService.shared.getRedditAuthentication()
        client.retrier = redditInterceptor
        client.adapter = redditInterceptor
        return client
    }()

    // user based oauth flow
    let user_client_id = "19p5y59lgeAA7Q"
    let redirect_uri = "lsf://response"
    let response_type = "code"
    let state = "random_string"
    let duration = "permanent"
    let scope = "identity%20save%20submit%20vote%20report%20read"
    let access_token_url = "https://www.reddit.com/api/v1/access_token"
    var userOauthClient: SessionManager?
    
    lazy var user_oauth_url = {
        return "https://www.reddit.com/api/v1/authorize.compact?client_id=\(self.user_client_id)&response_type=\(self.response_type)&state=\(self.state)&redirect_uri=\(self.redirect_uri)&duration=\(self.duration)&scope=\(self.scope)"
    }

    init(userAgent: String) {
        self.userAgent = userAgent
        self.setUserOauthClient()
    }
    
    func setUserOauthClient() {
        if let auth = StorageService.shared.getRedditUserAuthentication() {
            let client = SessionManager()
            let redditInterceptor = RedditInterceptorService(userAgent: self.userAgent, handlerFunc: self.setupUserOauthHandler)
            redditInterceptor.redditAuthentication = auth
            client.retrier = redditInterceptor
            client.adapter = redditInterceptor
            self.userOauthClient = client
        }
    }

    func setupInitialUserOauth(code: String, completion: ((_ auth: RedditAuthentication?) -> Void)?) {
        
        let params = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": self.redirect_uri,
        ]
        
        self.setupUserOauth(params: params, completion: { auth in
            self.setUserOauthClient()
            completion?(auth)
        })
    }
    
    private func setupUserOauth(params: [String : String], completion: ((_ auth: RedditAuthentication?) -> Void)?) {
        let credentials = "\(self.user_client_id):"
        
        let headers = [
            "User-Agent": self.userAgent,
            "Authorization": "Basic \(credentials.toBase64())"
        ]
        
        Alamofire.request(self.access_token_url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditAuthentication.self, from: res) {
                    // must always preserve refresh token because we don't get a new one back on refresh
                    if let currentAuth = StorageService.shared.getRedditUserAuthentication(), data.refresh_token == nil {
                        data.refresh_token = currentAuth.refresh_token
                    }
                    StorageService.shared.storeRedditUserAuthentication(auth: data)
                    completion?(data)
                } else {
                    completion?(nil)
                }
                break
            case .failure(let err):
                print(err)
                completion?(nil)
            }
        }
    }
    
    func setupUserOauthHandler(code: String?, completion: ((_ auth: RedditAuthentication?) -> Void)?) {
        guard let code = code else {
            completion?(nil)
            return
        }
        
        let params = [
            "grant_type": "refresh_token",
            "refresh_token": code,
        ]

        self.setupUserOauth(params: params, completion: completion)
    }
    
    /// set up non-user oauth
    /// code is not used - added to satisfy handlerfunc
    func setupNonUserOauthHandler(code: String?, completion: ((_ auth: RedditAuthentication?) -> Void)?) {
        
        let credentials = "\(self.non_user_client_id):"
        
        let headers = [
            "User-Agent": self.userAgent,
            "Authorization": "Basic \(credentials.toBase64())"
        ]
        
        let params = [
            "grant_type": "https://oauth.reddit.com/grants/installed_client",
            "device_id": "\(UUID.init().uuidString)"
        ]
        
        Alamofire.request(self.non_user_oauth_url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditAuthentication.self, from: res) {
                    StorageService.shared.storeRedditAuthentication(auth: data)
                    completion?(data)
                } else {
                    completion?(nil)
                }
                break
            case .failure(let err):
                completion?(nil)
                print(err)
            }
        }
    }
}
