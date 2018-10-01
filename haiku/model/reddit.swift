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
    var playerItem: CachingPlayerItem? = nil

    func getPlayerItem() -> Observable<CachingPlayerItem?> {
        return Observable<CachingPlayerItem?>.create { observer in
            self.fetchYoutubeStuff().subscribe( onCompleted: {
                observer.onNext(self.playerItem)
                observer.onCompleted()
            })
        }
    }
    
    func fetchYoutubeStuff() -> Observable<Any?> {
        if self.playerItem != nil {
            return Observable.of().share()
        }
        
        return Observable.create{ observer in
            if let id = self.url?.youtubeID {
                let client = XCDYouTubeClient.default()
                client.getVideoWithIdentifier(id) { (info, err) -> Void in
                    if let streamUrl = info?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                        ?? info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                        ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                        self.thumbnail.kf.setImage(with: info?.smallThumbnailURL)
                        self.playerItem = CachingPlayerItem(url: streamUrl, customFileExtension: "mp4")
                    }
                    observer.onCompleted()
                }
            } else {
                observer.onCompleted()
            }
            return Disposables.create()
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
