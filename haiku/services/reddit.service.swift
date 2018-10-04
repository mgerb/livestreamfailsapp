
import Alamofire

class RedditService {
    
    static let shared = RedditService()

    // returns a list of youtube ID's from youtube haiku
    func getHaikus(after: String?, closure: @escaping (_ data: [RedditPost]) -> Void) {
        var url = "https://reddit.com/r/youtubehaiku.json?limit=25"
        if (after != nil) {
            url = url + ("&after=" + after!)
        }
        
        Alamofire.request(url).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditData.self, from: res) {
                    let newData = data.data.children.compactMap { c in
                        // filter out reddit posts that don't contain youtube link
                        return c.data.url?.youtubeID == nil ? nil : c.data
                    }
                    closure(newData)
                }
            case .failure(_):
                closure([])
            }
        }
    }
}
