//  RedditComment.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import DynamicJSON
import IGListKit
import Down
import SwiftyMarkdown

class RedditComment {
    let id: String?
    let author: String?
    let body: String?
    let htmlBody: NSAttributedString?
    let depth: Int
    let ups: Int?
    let score: Int?
    let created: Int?
    var collapsed: Bool
    let children: [String]?
    
    /// more comments will contain a list of children ID's
    lazy var isMoreComment: Bool = {
        return (self.children?.count ?? 0) > 0
    }()

    init(json: JSON) {
        self.id = json.id.string
        self.body = json.body.string
        self.depth = json.depth.int ?? 0
        self.ups = json.ups.int
        self.score = json.score.int
        self.author = json.author.string
        self.created = json.created.int
        self.collapsed = json.collapsed.bool ?? false
        self.children = json.children.array?.compactMap { $0.string }

        // TODO: refine this - make normal links clickable
        let text = self.body ?? ""
        let regex = try! NSRegularExpression(pattern: "(^|[\\n\\r\\s]+)(https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))")
        let range = NSMakeRange(0, text.count)
        let newString: String = regex.stringByReplacingMatches(in: text, options: [], range:range , withTemplate: "$1[$2]($2)")
        
        let md = SwiftyMarkdown(string: newString)
        md.body.fontName = Config.smallFont.familyName
        md.body.fontSize = 12
        md.link.fontSize = 12
        self.htmlBody = md.attributedString()
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
