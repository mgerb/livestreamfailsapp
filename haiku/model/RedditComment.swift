//
//  RedditComment.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation

class RedditCommentListing: Decodable {
    let kind: String
    let data: RedditCommentListingData
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case data
    }
}

class RedditCommentListingData: Decodable {
    let modhash: String
    let children: [RedditCommentListingOrString]
    let after: String?
    let before: String?
    
    private enum CodingKeys: String, CodingKey {
        case modhash
        case children
        case after
        case before
    }
}

class RedditCommentChildren: Decodable {
    let kind: String
    let data: RedditComment
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case data
    }
}

// combined value to handle string/redditcommentlist because reddit api is shit
// and return a reply as a string and not a null - wtf?
enum RedditCommentListingOrString: Decodable {
    case redditCommentChildren(RedditCommentChildren), redditCommentListing(RedditCommentListing), string(String)

    init(from decoder: Decoder) throws {
        if let redditCommentChildren = try? decoder.singleValueContainer().decode(RedditCommentChildren.self) {
            self = .redditCommentChildren(redditCommentChildren)
            return
        }
        
        if let redditCommentListing = try? decoder.singleValueContainer().decode(RedditCommentListing.self) {
            self = .redditCommentListing(redditCommentListing)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        print(decoder)
        throw QuantumError.missingValue
    }

    enum QuantumError:Error {
        case missingValue
    }
}

class RedditComment: Decodable {
    let body: String?
    let replies: RedditCommentListingOrString?
    
    private enum CodingKeys: String, CodingKey {
        case body
        case replies
    }
}

