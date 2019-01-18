
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
    
    private func getComments(permalink: String, args: String = "", closure: @escaping ((_ data: JSON?) -> Void)) {
        let url = "https://www.reddit.com\(permalink).json?\(args)"
        Alamofire.request(url, headers: RedditService.headers).validate().responseJSON { response in
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
