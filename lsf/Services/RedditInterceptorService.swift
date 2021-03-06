//
//  reddit-interceptor.service..swift
//  lsf
//
//  Created by Mitchell Gerber on 5/29/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Alamofire

class RedditInterceptorService: RequestAdapter, RequestRetrier {
    
    var redditAuthentication: RedditAuthentication?
    private let userAgent: String
    private let lock = NSLock()
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var isRefreshingOauth = false
    private let handlerFunc: (_ code: String?, ((_ auth: RedditAuthentication?) -> Void)?) -> Void
    
    init(userAgent: String, handlerFunc: @escaping (_ code: String?, ((_ auth: RedditAuthentication?) -> Void)?) -> Void) {
        self.userAgent = userAgent
        self.handlerFunc = handlerFunc
    }
    
    /// intercept request before it's sent - attach authorization here
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("Bearer \(self.redditAuthentication?.access_token ?? "invalidtoken")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    /// if we get a 401 (unauthenticated) - get new auth token and then retry failed requests
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        self.lock.lock() ; defer { self.lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            self.requestsToRetry.append(completion)
            
            if !self.isRefreshingOauth {
                self.isRefreshingOauth = true
                self.handlerFunc(self.redditAuthentication?.refresh_token) { [weak self] auth in
                    self?.isRefreshingOauth = false
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    strongSelf.redditAuthentication = auth
                    
                    // only continue requests if auth request succeeds
                    strongSelf.requestsToRetry.forEach { $0(auth != nil, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
