
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
        var url = "https://reddit.com/r/youtubehaiku.json?limit=25"
        if (after != nil) {
            url = url + ("&after=" + after!)
        }

        Alamofire.request(url, headers: self.headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditPostListing.self, from: res) {
                    let newData = data.data.children.compactMap { val -> RedditPost? in
                        // filter out reddit posts that don't contain youtube link
                        if val.data.url?.youtubeID == nil {
                            return nil
                        }
                        return val.data
                    }
                    
                    closure(newData)
                }
            case .failure(_):
                closure([])
            }
        }
    }
    
    private func getComments(permalink: String, args: String = "", closure: @escaping ((_ data: JSON?) -> Void)) {
        let url = "https://www.reddit.com\(permalink).json?\(args)"
        Alamofire.request(url, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                closure(JSON(value)[1])
            case .failure(let error):
                print(error)
                closure(nil)
            }
        }
    }
    
    func getFlattenedComments(permalink: String, more: Bool = false, closure: @escaping ((_ data: [RedditComment]) -> Void)) {
        
        // if we are loading more comments need to pass context
        // to load from the highest parent - this is so that
        // we can get the depth levels correct and the
        // newly loaded comments will look right
        let args = more ? "context=10000" : ""

        self.getComments(permalink: permalink, args: args) {
            if let comments = $0 {
                let output = RedditComment.flattenReplies(replies: comments).compactMap {
                    RedditComment(json: $0)
                }
                closure(output)
            } else {
                closure([])
            }
        }
    }
}
