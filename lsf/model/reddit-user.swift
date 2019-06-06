//
//  reddit-user.swift
//  lsf
//
//  Created by Mitchell Gerber on 6/5/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Marshal

final class RedditUser: Unmarshaling {
    
    let name: String
    let over_18: Bool
    
    var redditAuthentication: RedditAuthentication?

    init(object: MarshaledObject) throws {
        self.name = try object.value(for: "name")
        self.over_18 = try object.value(for: "over_18")
        self.redditAuthentication = nil
    }
}
