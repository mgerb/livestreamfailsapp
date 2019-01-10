
import Alamofire
import SwiftyJSON

class RedditService {
    
    // use custom headers to allow NSFW content
    // it seems reddit blocks default iOS headers
    static let headers = [
        "User-Agent": "Yaiku App :)"
    ]
    static let shared = RedditService()

    // returns a list of youtube ID's from youtube haiku
    func getHaikus(after: String?, closure: @escaping (_ data: [RedditPost]) -> Void) {
        var url = "https://reddit.com/r/youtubehaiku.json?limit=25"
        if (after != nil) {
            url = url + ("&after=" + after!)
        }

        Alamofire.request(url, headers: RedditService.headers).responseData{ response in
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
    
    func getComments(permalink: String, closure: @escaping ((_ data: RedditCommentListing?) -> Void)) {
        let url = "https://www.reddit.com\(permalink).json"
        Alamofire.request(url, headers: RedditService.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = try? JSON(value)[1].rawData() {
                    let c: RedditCommentListing? = try? JSONDecoder().decode(RedditCommentListing.self, from: json)
                    closure(c)
                }
            case .failure(let error):
                print(error)
                closure(nil)
            }
        }
    }
    
    func getFlattenedComments(permalink: String, closure: @escaping ((_ data: [RedditComment]) -> Void)) {
        self.getComments(permalink: permalink) {
            if let comments = $0 {
                closure(self.flattenComments(comments: RedditCommentListingOrString.redditCommentListing(comments)))
            } else {
                closure([])
            }
        }
    }

    func flattenComments(comments: RedditCommentListingOrString?) -> [RedditComment] {

        if let com = comments {
            switch com {
            case .redditCommentListing(let c):
                let d: [[RedditComment]] = c.data.children.compactMap {
                    switch $0 {
                    case .redditCommentChildren(let child):
                        let a = [child.data]
                        let b = self.flattenComments(comments: child.data.replies)
                        print(b)
                        return a + b
                    default:
                        return []
                    }
                }
                print(d)
                return d.reduce([], +)
            default:
                return []
            }
        }

        return []
    }
}
