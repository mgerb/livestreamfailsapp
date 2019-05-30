
import Foundation
import Alamofire
import Marshal

class RedditAuthentication: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let device_id: String
    let expires_in: Int
}

enum RedditLinkSortBy: String {
    case hot = "hot"
    case new = "new"
    case rising = "rising"
    case controversial = "controversial"
    case top = "top"
}

enum RedditLinkSortByTop: String, CaseIterable {
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    case all = "all"
}

class RedditService {
    
    // use custom headers to allow NSFW content
    // it seems reddit blocks default iOS headers
    // user agent description here: https://github.com/reddit-archive/reddit/wiki/api
    let headers = [
        "User-Agent": "ios:\(String(describing: Bundle.main.bundleIdentifier)):\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.0.0")"
    ]
    static let shared = RedditService()
    let haikuLimit = 25
    lazy var redditAuth = RedditAuth(userAgent: self.headers["User-Agent"]!)

    // returns a list of youtube ID's from youtube haiku
    func getRedditLinks(after: String?, sortBy: RedditLinkSortBy, sortByTop: RedditLinkSortByTop?, closure: @escaping (_ data: [RedditLink]) -> Void) {
        let url = "https://reddit.com/r/livestreamfail/\(sortBy)/.json"
        var parameters = [
            "limit": String(self.haikuLimit)
        ]
        
        if let after = after {
            parameters["after"] = after
        }
        
        if sortBy == .top, let sortByTop = sortByTop {
            parameters["t"] = sortByTop.rawValue
        }

        let queue = DispatchQueue(label: "RedditService.getHaikus", qos: .utility, attributes: [.concurrent])
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.headers).validate()
            .response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { response in
                var links: [RedditLink] = []

                switch response.result {
                case .success(let res):
                    do {
                        let json = try JSONParser.JSONObjectWithData(res)
                        let thing = try RedditThing(object: json)
                        
                        if let data = thing.data, case .redditListing(let listing) = data, let children = listing.children {
                            children.forEach { child in
                                if let data = child.data, case .redditLink(let link) = data {
                                    links.append(link)
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let err):
                    print(err)
                }
    
                // filter nsfw links
                closure(self.filterRedditLinks(links: links))
        })
    }
    
    private func filterRedditLinks(links: [RedditLink]) -> [RedditLink] {
        return links.filter {
            // show show link if nsfw is turned off and post is nsfw
//            if !UserSettings.shared.nsfw && $0.over_18 {
//                return false
//            }
            // filter all nsfw posts for now
            if $0.over_18 {
                return false
            }
            
            // show show link if has been hidden by user
            if StorageService.shared.getHiddenPost(redditLink: $0) {
                return false
            }

            return true
        }
    }
    
    func getComments(permalink: String, params: Parameters = [:], closure: @escaping ((_ data: [RedditListingType]?) -> Void)) {
        let url = "https://www.reddit.com\(permalink).json"
        var params = params
        if params["limit"] == nil {
            params["limit"] = "100"
        }
        let queue = DispatchQueue(label: "RedditService.getComments", qos: .utility, attributes: [.concurrent])
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: self.headers).validate()
            .response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { response in
                switch response.result {
                case .success(let value):
                    do {
                        let json = try JSONParser.JSONArrayWithData(value)
                        let thing = try RedditThing(object: json[1])
                        
                        let flattenedComments = RedditComment.flattenComments(thing)
                        
                        // render html
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
                        flattenedComments.forEach { c in
                            if case .redditComment(let c) = c {
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
                            }
                        }
                        
                        dispatchGroup.wait()
                        
                        DispatchQueue.main.async {
                            closure(flattenedComments)
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        closure(nil)
                    }
                }
        })
    }
    
    func getFirstComment(permalink: String, closure: @escaping ((_ data: RedditComment?) -> Void)) {
        self.getComments(permalink: permalink, params: ["limit": 1]) {
            if let listing = $0, listing.count > 0 {
                if case .redditComment(let comment) = listing[0] {
                    closure(comment)
                    return
                }
            }
            closure(nil)
        }
    }

    /// load more comments from children
    /// link_id - should be the name of the reddit link
    // TODO:
    func getMoreComments(more: RedditMore, link_id: String, closure: @escaping (_ comments: [RedditListingType]) -> Void) {
        let params: [String: Any] = [
            "api_type": "json",
            "children": more.children.joined(separator: ","),
            "link_id": link_id,
            "limit_children": true
        ]

        self.redditAuth.oauthClient.request("https://oauth.reddit.com/api/morechildren", parameters: params).validate().responseData { response in
            switch response.result {
            case .success(let value):
                do {
                    let j = try JSONParser.JSONObjectWithData(value)
                    let things: [MarshalDictionary] = try j.value(for: "json").value(for: "data").value(for: "things")
                    
                    let newComments: [RedditListingType] = try things.compactMap {
                        let c: RedditComment = try $0.value(for: "data")
                        c.renderHtml()
                        return RedditListingType.redditComment(c)
                    }

                    closure(newComments)
                } catch {
                    print(error)
                    closure([])
                }
            case .failure(let error):
                print(error)
                closure([])
            }
        }
    }
    
    func checkRedditVideo(fallbackUrl: String, closure: @escaping (_ valid: Bool) -> Void) {
        Alamofire.request(fallbackUrl, method: .head, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseString(completionHandler: { resp in
                switch resp.result {
                case .success:
                    let contentType = resp.response?.allHeaderFields["Content-Type"] as? String
                    closure(contentType == "video/mp4")
                case .failure(let error):
                    print(error)
                    closure(false)
                }
        })
    }
}
