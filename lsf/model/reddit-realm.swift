//
//  reddit-realm.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/23/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmRedditLink: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var url: String?
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var permalink: String = ""
    @objc dynamic var score: Int = 0
    @objc dynamic var dateAdded: Date = Date()
    @objc dynamic var over_18: Bool = false
    @objc dynamic var author: String = ""
    @objc dynamic var ups: Int = 0
    @objc dynamic var is_self: Bool = false
    @objc dynamic var created: Float = 0.0
    @objc dynamic var created_utc: Float = 0.0
    @objc dynamic var archived: Bool = false
    @objc dynamic var pinned: Bool = false
    @objc dynamic var locked: Bool = false
    @objc dynamic var visited: Bool = false
    @objc dynamic var num_comments: Int = 0
    @objc dynamic var stickied: Bool = false
    @objc dynamic var previewUrl: String?
    @objc dynamic var previewWidth: Int = 0
    @objc dynamic var previewHeight: Int = 0
    @objc dynamic var fallbackUrl: String?
    
    convenience init(_ rp: RedditLink) {
        self.init()
        self.title = rp.title
        self.url = rp.url
        self.id = rp.id
        self.name = rp.name
        self.permalink = rp.permalink
        self.score = rp.score
        self.over_18 = rp.over_18
        self.author = rp.author
        self.ups = rp.ups
        self.is_self = rp.is_self
        self.created = rp.created
        self.created_utc = rp.created_utc
        self.archived = rp.archived
        self.pinned = rp.pinned
        self.locked = rp.locked
        self.visited = rp.visited
        self.num_comments = rp.num_comments
        self.stickied = rp.stickied
        self.previewUrl = rp.previewUrl
        self.previewHeight = rp.previewHeight ?? 0
        self.previewWidth = rp.previewWidth ?? 0
        self.fallbackUrl = rp.fallbackUrl
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getRedditLink() -> RedditLink {
        return RedditLink(rrp: self)
    }
}
