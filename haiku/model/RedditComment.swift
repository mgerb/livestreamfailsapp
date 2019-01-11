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
    let depth: Int?
    let ups: Int?
    let score: Int?
    let created: Int?

    init(json: JSON) {
        self.id = json.id.string
        self.body = json.body.string
        self.depth = json.depth.int
        self.ups = json.ups.int
        self.score = json.score.int
        self.author = json.author.string
        self.created = json.created.int
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
