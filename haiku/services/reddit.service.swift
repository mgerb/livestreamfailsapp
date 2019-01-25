
import Foundation
import Alamofire
import SwiftyJSON

class RedditAuthentication: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let device_id: String
    let expires_in: Int
}

class RedditService: RequestAdapter, RequestRetrier {
    
    // use custom headers to allow NSFW content
    // it seems reddit blocks default iOS headers
    // user agent description here: https://github.com/reddit-archive/reddit/wiki/api
    let headers = [
        "User-Agent": "ios:\(String(describing: Bundle.main.bundleIdentifier)):\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.0.0")"
    ]
    static let shared = RedditService()
    let client_id = "Y2NoNa4zUyLbCA"
    let password = ""
    let oauthUrl = "https://www.reddit.com/api/v1/access_token"
    var accessToken: String?
    var expires_in: Date?
    var redditAuthentication: RedditAuthentication?
    
    /// separate Alamofire instance for authenticated requests
    let oauthClient = SessionManager()
    private let lock = NSLock()
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var isRefreshingOauth = false

    init() {
        self.oauthClient.retrier = self
        self.oauthClient.adapter = self
        self.redditAuthentication = StorageService.shared.getRedditAuthentication()
    }

    /// intercept request before it's sent - attach authorization here
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(self.headers["User-Agent"], forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("Bearer \(self.redditAuthentication?.access_token ?? "invalidtoken")", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    /// if we get a 401 (unauthenticated) - get new auth token and then retry failed requests
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        self.lock.lock() ; defer { self.lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            self.requestsToRetry.append(completion)
            
            if !self.isRefreshingOauth {
                self.setupOauth { [weak self] succeeded in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    // only continue requests if auth request succeeds
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    func setupOauth(completion: ((_ success: Bool) -> Void)?) {

        self.isRefreshingOauth = true
        
        let credentials = "\(self.client_id):\(self.password)"
        
        let headers = [
            "User-Agent": self.headers["User-Agent"]!,
            "Authorization": "Basic \(credentials.toBase64())"
        ]
        
        let params = [
            "grant_type": "https://oauth.reddit.com/grants/installed_client",
            "device_id": "\(UUID.init().uuidString)"
        ]
        
        Alamofire.request(self.oauthUrl, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseData{ response in
            defer {
                self.isRefreshingOauth = false
            }
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditAuthentication.self, from: res) {
                    StorageService.shared.storeRedditAuthentication(auth: data)
                    self.redditAuthentication = data
                    completion?(true)
                } else {
                    completion?(false)
                }
                break
            case .failure(let err):
                completion?(false)
                print(err)
            }
        }
    }

    // returns a list of youtube ID's from youtube haiku
    func getHaikus(after: String?, closure: @escaping (_ data: [RedditPost]) -> Void) {
        var url = "https://reddit.com/r/livestreamfail.json?limit=25"
        if (after != nil) {
            url = url + ("&after=" + after!)
        }

        Alamofire.request(url, headers: self.headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditPostListing.self, from: res) {
                    let newData = data.data.children.compactMap { $0.data }
                    closure(newData)
                }
            case .failure(_):
                closure([])
            }
        }
    }
    
    private func getComments(permalink: String, params: Parameters = [:], closure: @escaping ((_ data: JSON?) -> Void)) {
        let url = "https://www.reddit.com\(permalink).json"
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.httpBody, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                closure(JSON(value)[1])
            case .failure(let error):
                print(error)
                closure(nil)
            }
        }
    }
    
    func getFirstComment(permalink: String, closure: @escaping ((_ data: RedditComment?) -> Void)) {
        self.getComments(permalink: permalink, params: ["limit": 1]) {
            if let data = $0?["data"]["children"][0]["data"] {
                closure(RedditComment(json: data))
            } else {
                closure(nil)
            }
        }
    }

    func getFlattenedComments(permalink: String, closure: @escaping ((_ data: [RedditComment]) -> Void)) {
        self.getComments(permalink: permalink) {
            if let comments = $0 {
                
                // This is a hack to load comments more quickly because it's a little
                // slow rendering all the html into an NSAttributedString.
                // All html is rendered asynchronously on the globa queue,
                // but we only wait for the first 10 to render before the callback.
                // This is so that we have them first rendered when the list shows
                // up. The rest of the comments will continue to render asynchronously
                // on the global queue, but we won't wait for them. Seems to work
                // okay only waiting for 10.
                // https://www.raywenderlich.com/5371-grand-central-dispatch-tutorial-for-swift-4-part-2-2
                var count = 0
                let dispatchGroup = DispatchGroup()
                let output: [RedditComment] = RedditComment.flattenReplies(replies: comments).compactMap {
                    let c = RedditComment(json: $0)
                    if count < 10 {
                        dispatchGroup.enter()
                        DispatchQueue.global().async {
                            c.renderHtml()
                            dispatchGroup.leave()
                        }
                        count += 1
                    } else {
                        DispatchQueue.global().async {
                            c.renderHtml()
                        }
                    }
                    return c
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    closure(output)
                }
            } else {
                closure([])
            }
        }
    }
    
    /// load more comments from children
    /// link_id - should be the name of the reddit post
    func getMoreComments(comment: RedditComment, link_id: String, closure: @escaping (_ comments: [RedditComment]) -> Void) {
        let params: [String: Any] = [
            "api_type": "json",
            "children": comment.children?.joined(separator: ",") ?? "",
            "link_id": link_id,
            "limit_children": true
        ]
        
        self.oauthClient.request("https://oauth.reddit.com/api/morechildren", parameters: params).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                // TODO: may need to implement asynchronous html render here like above
                let newComments: [RedditComment] = json["json"]["data"]["things"].array?.compactMap {
                    let c = RedditComment(json: $0["data"])
                    c.renderHtml()
                    return c
                } ?? []
                
                closure(newComments)
            case .failure(let error):
                print(error)
                closure([])
            }
        }
    }
}
