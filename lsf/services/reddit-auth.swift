//
//  RedditAuth.swift
//  lsf
//
//  Created by Mitchell Gerber on 5/29/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Alamofire

class RedditAuth {
    
    let userAgent: String
    let nonUserClientID = "Y2NoNa4zUyLbCA"
    let nonUserOauthUrl = "https://www.reddit.com/api/v1/access_token"

    init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    lazy var oauthClient: SessionManager = {
        let client = SessionManager()
        let redditInterceptor = RedditInterceptor(userAgent: self.userAgent, handlerFunc: self.setupNonUserOauth)
        client.retrier = redditInterceptor
        client.adapter = redditInterceptor
        let redditAuthentication = StorageService.shared.getRedditAuthentication()
        redditInterceptor.accessToken = redditAuthentication?.access_token
        return client
    }()
    
    /// TODO:
//    lazy var userOauthClient: SessionManager = {
//        return SessionManager()
//    }()
    
    /// set up non-user oauth
    func setupNonUserOauth(completion: ((_ accessToken: String?) -> Void)?) {
        
        let credentials = "\(self.nonUserClientID):"
        
        let headers = [
            "User-Agent": self.userAgent,
            "Authorization": "Basic \(credentials.toBase64())"
        ]
        
        let params = [
            "grant_type": "https://oauth.reddit.com/grants/installed_client",
            "device_id": "\(UUID.init().uuidString)"
        ]
        
        Alamofire.request(self.nonUserOauthUrl, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditAuthentication.self, from: res) {
                    StorageService.shared.storeRedditAuthentication(auth: data)
                    completion?(data.access_token)
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
