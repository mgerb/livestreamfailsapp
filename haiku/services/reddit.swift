
import Foundation
import Alamofire

struct RedditData: Codable {
    let kind: String
    let data: RedditDataInfo
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case data
    }
}

struct RedditDataInfo: Codable {
    let dist: Int
    let modhash: String
    let children: [RedditChildren]
    let after: String?
    let before: String?

    private enum CodingKeys: String, CodingKey {
        case dist
        case modhash
        case children
        case after
        case before
    }
}

struct RedditChildren: Codable {
    let kind: String
    let data: RedditPost
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case data
    }
}

struct RedditPost: Codable {
    let title: String
    let url: String?
    let id: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case id
        case name
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}

class RedditService {
    
    static let shared = RedditService()

    // returns a list of youtube ID's from youtube haiku
    func getHaikus(after: String?, closure: @escaping (_ data: [RedditPost]) -> Void) {
        var url = "https://reddit.com/r/youtubehaiku.json"
        if (after != nil) {
            url = url + ("?after=" + after!)
        }
        
        Alamofire.request(url).responseData{ response in
            switch response.result {
            case .success(let res):
                if let data = try? JSONDecoder().decode(RedditData.self, from: res) {
                    let newData = data.data.children.map{ c in
                        return c.data
                    }
                    closure(newData)
                }
            case .failure(_):
                closure([])
            }
        }
    }
}
