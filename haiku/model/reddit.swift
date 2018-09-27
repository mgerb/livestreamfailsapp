//
//  reddit.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import IGListKit
import XCDYouTubeKit

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

class RedditPost: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case id
        case name
    }
    
    let title: String
    let url: String?
    let id: String
    let name: String
    var thumbnailURL: URL?
    let thumbnail = UIImageView()
    var streamURL: URL?
    var playerItem: AVPlayerItem? = nil

    func getPlayerItem(closure: @escaping (_ playerItem: AVPlayerItem?) -> Void) {
        self.getPlayerUrl{ url in
            if let u = url {
                self.playerItem = AVPlayerItem(url: u)
                closure(self.playerItem)
            } else {
                closure(nil)
            }
        }
    }
    
    func getPlayerUrl(closure: @escaping (_ url: URL?) -> Void) {
        if let id = self.url?.youtubeID {
            let client = XCDYouTubeClient.default()
            client.getVideoWithIdentifier(id) { (info, err) -> Void in
                if let streamUrl = info?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                    ?? info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                    ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                    self.thumbnailURL = info?.smallThumbnailURL
                    self.thumbnail.kf.setImage(with: self.thumbnailURL)
                    self.streamURL = streamUrl
                    closure(streamUrl)
                } else {
                    closure(nil)
                }
            }
        } else {
            closure(nil)
        }
    }
    
}

extension RedditPost: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? RedditPost {
            return self.id == object.id
        }
        return false
    }
}
