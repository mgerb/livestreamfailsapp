
import Alamofire

class RedditService {
    
    static let shared = RedditService()

    // returns a list of youtube ID's from youtube haiku
    func getHaikus(after: String?, closure: @escaping (_ data: [RedditPost]) -> Void) {
        var url = "https://reddit.com/r/youtubehaiku.json?limit=25"
        if (after != nil) {
            url = url + ("&after=" + after!)
        }
        
        // use custom headers to allow NSFW content
        // it seems reddit blocks default iOS headers
        let headers = [
            "User-Agent": "Youtube Haiku App :)"
        ]
        
        Alamofire.request(url, headers: headers).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditData.self, from: res) {
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
}
