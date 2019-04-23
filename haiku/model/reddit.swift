//
//  reddit.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/22/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Marshal

enum RedditKind: String {
    case listing = "Listing"
    case link = "t3"
    case comment = "t1"
}

struct RedditThing: Unmarshaling {
    
    let id: String?
    let kind: RedditKind
    let data: RedditListing?
    let name: String?
    
    init(object: MarshaledObject) throws {
        self.id = try object.value(for: "id")
        self.kind = try object.value(for: "kind")
        self.data = try object.value(for: "data")
        self.name = try object.value(for: "name")
    }
    
}

struct RedditListing: Unmarshaling {
    
    let children: [RedditThing]?
    
    init(object: MarshaledObject) throws {
        self.children = try object.value(for: "children")
    }
    
}

struct Post {
    
}

struct Comment {
    
}
