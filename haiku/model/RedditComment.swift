//  RedditComment.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import DynamicJSON
import IGListKit

class RedditComment {
    let id: String?
    let author: String?
    let body: String?
//    let htmlBody: NSAttributedString?
    let depth: Int
    let ups: Int?
    let score: Int?
    let created: Int?
    var collapsed: Bool
    let children: [String]?

    init(json: JSON) {
        self.id = json.id.string
        self.body = json.body.string
//        self.htmlBody = json.body.string?.htmlToAttributedString
        self.depth = json.depth.int ?? 0
        self.ups = json.ups.int
        self.score = json.score.int
        self.author = json.author.string
        self.created = json.created.int
        self.collapsed = json.collapsed.bool ?? false
        self.children = json.children.array?.compactMap { $0.string }
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
