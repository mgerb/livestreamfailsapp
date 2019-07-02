//
//  reddit.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/22/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Marshal
import DifferenceKit

enum RedditKind: String {
    case listing = "Listing"
    case link = "t3"
    case comment = "t1"
    case more = "more"
}

indirect enum RedditListingType {
    case redditListing(RedditListing)
    case redditLink(RedditLink)
    case redditComment(RedditComment)
    case redditMore(RedditMore)
}

struct RedditThing: Unmarshaling {
    
    let id: String?
    let kind: RedditKind
    let name: String?
    let data: RedditListingType?
    
    init(object: MarshaledObject) throws {
        self.id = try object.value(for: "id")
        self.kind = try object.value(for: "kind")
        self.name = try object.value(for: "name")
        
        switch self.kind {
        case .link:
            self.data = .redditLink(try object.value(for: "data"))
        case .listing:
            self.data = .redditListing(try object.value(for: "data"))
        case .comment:
            self.data = .redditComment(try object.value(for: "data"))
        case .more:
            self.data = .redditMore(try object.value(for: "data"))
        }
    }
}

struct RedditListing: Unmarshaling {
    let before: String?
    let after: String?
    let dist: Int?
    let modhash: String?
    let children: [RedditThing]?
    
    init(object: MarshaledObject) throws {
        self.before = try object.value(for: "before")
        self.after = try object.value(for: "after")
        self.children = try object.value(for: "children")
        self.modhash = try object.value(for: "modhash")
        self.dist = try object.value(for: "dist")
    }
}

struct RedditLink: Unmarshaling {
    let title: String
    let url: String?
    let id: String
    let name: String
    let permalink: String
    let score: Int
    let over_18: Bool
    let author: String
    let ups: Int
    let is_self: Bool
    let created: Float
    let created_utc: Float
    let archived: Bool
    let pinned: Bool
    let locked: Bool
    let visited: Bool
    let num_comments: Int
    let stickied: Bool
    var likes: Bool?

    // the reddit data structure for preview is more nested objects
    // but we only need one preview thumbnail so we mutate the
    // json data when we pull it back.
    // This makes it much easier to deal with and store with realm.
    var previewUrl: String? = nil
    var previewWidth: Int? = nil
    var previewHeight: Int? = nil
    
    // fallback video url - this is for v.redd.it videos - else will be nil
    var fallbackUrl: String? = nil
    
    // added from realm
    var dateAdded: Date? = nil
    
    init(object: MarshaledObject) throws {
        self.title = try object.value(for: "title")
        self.url = try object.value(for: "url")
        self.id = try object.value(for: "id")
        self.name = try object.value(for: "name")
        self.permalink = try object.value(for: "permalink")
        self.score = try object.value(for: "score")
        self.over_18 = try object.value(for: "over_18")
        self.author = try object.value(for: "author")
        self.ups = try object.value(for: "ups")
        self.is_self = try object.value(for: "is_self")
        self.created = try object.value(for: "created")
        self.created_utc = try object.value(for: "created_utc")
        self.archived = try object.value(for: "archived")
        self.pinned = try object.value(for: "pinned")
        self.locked = try object.value(for: "locked")
        self.visited = try object.value(for: "visited")
        self.num_comments = try object.value(for: "num_comments")
        self.stickied = try object.value(for: "stickied")
        self.likes = try object.value(for: "likes")
        
        self.fallbackUrl = try? object.value(for: "media").value(for: "reddit_video").value(for: "fallback_url")
        
        do {
            let images: [JSONObject] = try object.value(for: "preview").value(for: "images")
            let source: JSONObject = try images[0].value(for: "source")
            self.previewUrl = try source.value(for: "url")
            self.previewWidth = try source.value(for: "width")
            self.previewHeight = try source.value(for: "height")
        } catch {
            // do nothing
        }
    }
    
    // additional init for realm reddit link
    init(rrp: RealmRedditLink) {
        self.title = rrp.title
        self.url = rrp.url
        self.id = rrp.id
        self.name = rrp.name
        self.permalink = rrp.permalink
        self.score = rrp.score
        self.over_18 = rrp.over_18
        self.author = rrp.author
        self.ups = rrp.ups
        self.is_self = rrp.is_self
        self.created = rrp.created
        self.created_utc = rrp.created_utc
        self.archived = rrp.archived
        self.pinned = rrp.pinned
        self.locked = rrp.locked
        self.visited = rrp.visited
        self.num_comments = rrp.num_comments
        self.stickied = rrp.stickied
        
        self.previewUrl = rrp.previewUrl
        self.previewHeight = rrp.previewHeight
        self.previewWidth = rrp.previewWidth
        self.dateAdded = rrp.dateAdded
        self.fallbackUrl = rrp.fallbackUrl
        self.likes = rrp.likes
    }
}

protocol RedditCommentProtocol: class {
    var id: String { get }
    var depth: Int { get }
    var name: String { get }
    var parent_id: String { get }
    var isHidden: Bool { get set }
}

protocol RedditCommentDelegate {
    func didUpdateLikes(comment: RedditComment)
}

final class RedditComment: RedditCommentProtocol, Unmarshaling, Differentiable {

    var delegate: RedditCommentDelegate?
    let id: String
    let parent_id: String
    let name: String
    let link_id: String
    let author: String
    let body: String
    let body_html: String
    let depth: Int
    let ups: Int
    let score: Int
    let created: Float
    let created_utc: Float
    let permalink: String?
    /// if user up/down voted
    var likes: Bool? {
        didSet {
            self.delegate?.didUpdateLikes(comment: self)
        }
    }
    let replies: RedditThing?
    
    // self defined values not on reddit json
    var htmlBody: NSAttributedString? = nil
    var isCollapsed: Bool = false
    var isHidden: Bool = false
    
    init(object: MarshaledObject) throws {
        self.id = try object.value(for: "id")
        self.parent_id = try object.value(for: "parent_id")
        self.name = try object.value(for: "name")
        self.link_id = try object.value(for: "link_id")
        self.author = try object.value(for: "author")
        self.body = try object.value(for: "body")
        self.body_html = try object.value(for: "body_html")
        self.depth = try object.value(for: "depth")
        self.ups = try object.value(for: "ups")
        self.score = try object.value(for: "score")
        self.created = try object.value(for: "created")
        self.created_utc = try object.value(for: "created_utc")
        self.permalink = try object.value(for: "permalink")
        // empty replies are returned as an empty string for whatever reason
        self.replies = try? object.value(for: "replies")
        self.likes = try? object.value(for: "likes")
    }

    /// check if author is "[deleted]"
    var isDeleted: Bool {
        return self.author == "[deleted]"
    }

    /// return how much time past since now in readable format
    lazy var humanTimeStamp: String = {
        let timestamp = Date(timeIntervalSince1970: Double(self.created_utc))
        return Date().offset(from: timestamp)
    }()
    
    func renderHtml() {
        let style = """
            <style type=\"text/css\">
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    font-size: 14px;
                    color: #424242;
                }
                a {
                    text-decoration: none;
                }
            </style>
        """
        
        let htmlContent = "<!DOCTYPE html><html>\(style)<body>\(self.body_html.htmlToAttributedString?.string ?? "")</body></html>"
        self.htmlBody = htmlContent.htmlToAttributedString?.trimWhiteSpace()
    }

    /// create flat list of either more or comment type
    static func flattenComments(_ listing: RedditThing) -> [RedditListingType] {
        var output: [RedditListingType] = []
        
        guard let data = listing.data else { return output }
        
        switch data {
        case .redditComment(let comment):
            output = output + [data]
            if let replies = comment.replies {
                output = output + RedditComment.flattenComments(replies)
            }
            
        case .redditListing(let listing):
            if let children = listing.children {
                children.forEach { child in
                    output = output + RedditComment.flattenComments(child)
                }
            }
            
        case .redditMore(_):
            output = output + [data]
        default:
            break
        }
        
        return output
    }
    
    func getPermalink() -> URL? {
        if let p = self.permalink, let url = URL(string: "https://reddit.com" + p) {
            return url
        }
        return nil
    }
    
    var differenceIdentifier: String {
        return self.id
    }
    
    func isContentEqual(to source: RedditComment) -> Bool {
        return self.id == source.id
    }
}

final class RedditMore: RedditCommentProtocol, Unmarshaling, Differentiable {
    let id: String
    let parent_id: String
    let name: String
    let count: Int?
    let depth: Int
    let children: [String]
    var isHidden = false
    
    init(object: MarshaledObject) throws {
        self.count = try object.value(for: "count")
        self.name = try object.value(for: "name")
        self.id = try object.value(for: "id")
        self.parent_id = try object.value(for: "parent_id")
        self.depth = try object.value(for: "depth")
        self.children = try object.value(for: "children")
    }
    
    var isContinueThread: Bool {
        return self.id == "_"
    }
    
    var differenceIdentifier: String {
        return self.id
    }
    
    func isContentEqual(to source: RedditMore) -> Bool {
        return self.id == source.id
    }
    
}
