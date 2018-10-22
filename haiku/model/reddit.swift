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
    
    convenience init(_ redditPost: RedditPost) {
        self.init()
        self.title = redditPost.title
        self.url = redditPost.url
        self.id = redditPost.id
        self.name = redditPost.name
        self.permalink = redditPost.permalink
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getRedditPost() -> RedditPost {
        return RedditPost(title: self.title, url: self.url, id: self.id, name: self.name, permalink: self.permalink)
    }
}

class RedditPost: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case id
        case name
        case permalink
    }
    
    let title: String
    let url: String?
    let id: String
    let name: String
    let permalink: String
    
    var favorited = false
    var expandTitle = false
    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        if let youtubeID = self.url?.youtubeID {
            // cache thumbnail with KF
            view.kf.setImage(with: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
        }
        return view
    }()
    private var cachedPlayerItem: CachingPlayerItem? = nil
    lazy var playerItemObservable: Observable<CachingPlayerItem?> = self.getPlayerItem()
    
    init(title: String, url: String?, id: String, name: String, permalink: String) {
        self.title = title
        self.url = url
        self.id = id
        self.name = name
        self.permalink = permalink
    }

    func getPlayerItem() -> Observable<CachingPlayerItem?> {
        return Observable.create { observer in
            let dispose = Disposables.create()

            if self.cachedPlayerItem == nil {
                if let storedItemData = StorageService.shared.getCachedVideo(id: self.id) {
                    self.cachedPlayerItem = CachingPlayerItem(data: storedItemData, mimeType: "video/mp4", fileExtension: "mp4")
                }
            }

            if self.cachedPlayerItem != nil {
                observer.onNext(self.cachedPlayerItem)
                observer.onCompleted()
                return dispose
            }
            
            if let id = self.url?.youtubeID {
                let client = XCDYouTubeClient.default()
                client.getVideoWithIdentifier(id) { (info, err) -> Void in
                    if let streamUrl =  info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                        ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                        self.cachedPlayerItem = CachingPlayerItem(url: streamUrl, customFileExtension: "mp4")
                        self.cachedPlayerItem?.delegate = self
                        observer.onNext(self.cachedPlayerItem)
                    }
                    observer.onCompleted()
                }
            } else {
                observer.onCompleted()
            }
            return dispose
        }.share()
    }
}


extension RedditPost: CachingPlayerItemDelegate {

    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        StorageService.shared.cacheVideoData(data: data, id: self.id)
    }
    
    // func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
    //     print("\(bytesDownloaded)/\(bytesExpected)")
    // }
    
    // func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
    //     print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    // }
    
    // func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
    //     print(error)
    // }
    
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
