//
//  RedditSectionViewItem.swift
//  haiku
//
//  Created by Mitchell Gerber on 11/11/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import IGListKit
import XCDYouTubeKit
import RxSwift

enum RedditViewItemContext {
    case home
    case favorites
}

class RedditViewItem {
    let redditPost: RedditPost
    var context: RedditViewItemContext

    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        if let youtubeID = self.redditPost.url?.youtubeID {
            // cache thumbnail with KF
            view.kf.setImage(with: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
        }
        return view
    }()
    private var cachedPlayerItem: CachingPlayerItem? = nil
    lazy var playerItemObservable: Observable<CachingPlayerItem?> = self.getPlayerItem()
    
    init(_ redditPost: RedditPost, context: RedditViewItemContext) {
        self.redditPost = redditPost
        self.context = context
    }
    
    func getPlayerItem() -> Observable<CachingPlayerItem?> {
        return Observable.create { observer in
            let dispose = Disposables.create()
            
            if self.cachedPlayerItem == nil {
                if let storedItemData = StorageService.shared.getCachedVideo(id: self.redditPost.id) {
                    self.cachedPlayerItem = CachingPlayerItem(data: storedItemData, mimeType: "video/mp4", fileExtension: "mp4")
                }
            }
            
            if self.cachedPlayerItem != nil {
                observer.onNext(self.cachedPlayerItem)
                observer.onCompleted()
                return dispose
            }
            
            if let id = self.redditPost.url?.youtubeID {
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

extension RedditViewItem: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        StorageService.shared.cacheVideoData(data: data, id: self.redditPost.id)
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

extension RedditViewItem: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.redditPost.id as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? RedditViewItem {
            return self.redditPost.id == object.redditPost.id
        }
        return false
    }
}
