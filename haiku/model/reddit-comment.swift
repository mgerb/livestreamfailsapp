//  RedditComment.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import IGListKit
import SwiftyJSON

class RedditComment {
    let id: String?
    let parent_id: String?
    let link_id: String?
    let author: String?
    let body: String?
    let body_html: String?
    var htmlBody: NSMutableAttributedString?
    let depth: Int
    let ups: Int?
    let score: Int?
    let created: Int?
    let created_utc: Int?
    let children: [String]?
    let permalink: String?
    let replies: JSON

    // self defined values not on reddit json
    var isCollapsed: Bool
    var isHidden: Bool
    
    /// more comments will contain a list of children ID's
    var isMoreComment: Bool {
        return (self.children?.count ?? 0) > 0
    }
    
    /// check if author is "[deleted]"
    var isDeleted: Bool {
        return self.author == "[deleted]"
    }
    
    /// if comment is "continue this thread" comment
    var isContinueThread: Bool {
        return self.id == "_"
    }
    
    /// return how much time past since now in readable format
    lazy var humanTimeStamp: String = {
        let timestamp = Date(timeIntervalSince1970: Double(self.created_utc ?? 0))
        return Date().offset(from: timestamp)
    }()

    init(json: JSON) {
        self.id = json["id"].string
        self.parent_id = json["parent_id"].string
        self.link_id = json["link_id"].string
        self.body = json["body"].string
        self.body_html = json["body_html"].string
        self.depth = json["depth"].int ?? 0
        self.ups = json["ups"].int
        self.score = json["score"].int
        self.author = json["author"].string
        self.created = json["created"].int
        self.created_utc = json["created_utc"].int
        self.children = json["children"].array?.compactMap { $0.string }
        self.permalink = json["permalink"].string
        self.replies = json["replies"]
        
        self.isCollapsed = false
        self.isHidden = false
    }
    
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
        
        let htmlContent = "<!DOCTYPE html><html>\(style)<body>\(self.body_html?.htmlToAttributedString?.string ?? "")</body></html>"
        self.htmlBody = htmlContent.htmlToAttributedString?.trimEndingNewLine()
    }
    
    func getFlattenedReplies() -> [RedditComment] {
        if self.replies.string != nil {
            return  []
        }
        
        return RedditComment.flattenReplies(replies: self.replies).compactMap {
            RedditComment(json: $0)
        }
    }
    
    func getLeftBorderColor() -> UIColor {
        let colors = [
            Config.colors.yellow,
            Config.colors.blue,
            Config.colors.red,
            Config.colors.green,
            Config.colors.purple,
            Config.colors.orange,
            Config.colors.tealBlue,
            Config.colors.pink,
        ]
        
        return colors[self.depth % 8]
    }
    
    static func flattenReplies(replies: JSON) -> [JSON] {
        let list: [[JSON]] = replies["data"]["children"].array?.compactMap { val in
            let data = val["data"]
            return [data] + RedditComment.flattenReplies(replies: data["replies"])
            } ?? []
        
        return list.reduce([], +)
    }
}

extension RedditComment: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return (self.id ?? "") as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? RedditComment {
            return self.id == object.id
        }
        return false
    }
}
