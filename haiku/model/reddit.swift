//
//  reddit.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import IGListKit
import XCDYouTubeKit
import RxSwift
import Cache
import Realm
import RealmSwift

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

class RealmRedditPost: Object {
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
    
    convenience init(_ rp: RedditPost) {
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
    }

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getRedditPost() -> RedditPost {
        return RedditPost(rrp: self)
    }
}

class RedditPost: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case id
        case name
        case permalink
        case score
        case over_18
        case author
        case ups
        case is_self
        case created
        case created_utc
        case archived
        case pinned
        case locked
        case visited
        case num_comments
        case stickied
    }
    
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
    let created: Float // created at timestamp
    let created_utc: Float
    let archived: Bool
    let pinned: Bool
    let locked: Bool
    let visited: Bool
    let num_comments: Int
    let stickied: Bool
    var favorited = false
    var dateAdded: Date?

    init(rrp: RealmRedditPost) {
        self.title = rrp.title
        self.url = rrp.url
        self.id = rrp.id
        self.name = rrp.name
        self.permalink = rrp.permalink
        self.score = rrp.score
        self.dateAdded = rrp.dateAdded
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
    }
}
