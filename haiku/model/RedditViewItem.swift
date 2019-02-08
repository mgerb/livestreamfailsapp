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
import Kingfisher

enum RedditViewItemContext {
    case home
    case favorites
}

enum RedditViewItemPlayerState {
    case idle
    case loading
    case error
}

class RedditViewItem {
    let redditPost: RedditPost
    let disposeBag = DisposeBag()

    /// context of where item is being used - either home or favorites page
    var context: RedditViewItemContext
    
    lazy var favorited = BehaviorSubject<Bool>(value: StorageService.shared.redditPostFavoriteExists(id: self.redditPost.id))
    lazy var markedAsWatched = BehaviorSubject<Bool>(value: StorageService.shared.getWatchedRedditPost(redditPost: self.redditPost))
    lazy var playerProgress = BehaviorSubject<Double>(value: 0.0)

    lazy var videoStartTime: Int = self.redditPost.url?.youtubeStartTime ?? 0
    lazy var videoEndTime: Int? = self.redditPost.url?.youtubeEndTime

    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        if let youtubeID = self.redditPost.url?.youtubeID {
            // cache thumbnail with KF
            view.kf.setImage(with: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
        } else {
            // TODO: cache image url's here somehow
            self.getPlayerItem().subscribe()
        }
        return view
    }()
    private var cachedPlayerItem: CachingPlayerItem? = nil
    
    lazy var humanTimeStampExtended: String = {
        return Date().offsetExtended(from: Date(timeIntervalSince1970: TimeInterval(Int(self.redditPost.created_utc))))
    }()

    init(_ redditPost: RedditPost, context: RedditViewItemContext) {
        self.redditPost = redditPost
        self.context = context
        self.setupSubscriptions()
    }
    
    func getPlayerItem() -> Observable<(CachingPlayerItem?, URL?)> {
        return Observable.create { observer in

            let dispose = Disposables.create()
            
            if self.cachedPlayerItem == nil {
                if let storedItemData = StorageService.shared.getCachedVideo(id: self.redditPost.id) {
                    self.cachedPlayerItem = CachingPlayerItem(data: storedItemData, mimeType: "video/mp4", fileExtension: "mp4")
                }
            }
            
            if self.cachedPlayerItem != nil {
                observer.onNext((self.cachedPlayerItem, nil))
                observer.onCompleted()
                return dispose
            }

            
            ClipUrlService.shared.getClipInfo(redditPost: self.redditPost) { (videoUrl, thumbnailUrl) in
                // if we get video url
                if let videoUrl = videoUrl {
                    if videoUrl.absoluteString.hasSuffix("mp4") {
                        self.cachedPlayerItem = CachingPlayerItem(url: videoUrl)
                    } else {
                        self.cachedPlayerItem = CachingPlayerItem(url: videoUrl, customFileExtension: "mp4")
                    }

                    self.cachedPlayerItem?.delegate = self
                }

                // if we get image url
                // TODO: this will be changed
                if let thumbnailUrl = thumbnailUrl {
                    // set thumbnail if we get it back
                    DispatchQueue.main.async {
                        self.thumbnail.kf.setImage(with: thumbnailUrl)
                    }
                }
                
                observer.onNext((self.cachedPlayerItem, thumbnailUrl))
                observer.onCompleted()
            }

            return dispose
        }.share()
    }

    func updateGlobalPlayer() {
        self.getPlayerItem().subscribe(onNext: { (item, _) in
            if let item = item {
                StorageService.shared.storeWatchedRedditPost(redditPost: self.redditPost)
                self.markedAsWatched.onNext(true)
                GlobalPlayer.shared.replaceItem(item, self)
            }
        })
    }
    
    func toggleFavorite() {
        if try! self.favorited.value() {
            self.favorited.onNext(false)
            StorageService.shared.deleteRedditPostFavorite(id: self.redditPost.id)
            // pause player if removing playing video from favorites
            if GlobalPlayer.shared.isActivePlayerItem(item: self) && self.context == .favorites {
                GlobalPlayer.shared.pause()
            }
        } else {
            self.favorited.onNext(true)
            StorageService.shared.storeRedditPostFavorite(redditPost: self.redditPost)
        }
        Subjects.shared.favoriteButtonAction.onNext(self)
        Util.hapticFeedbackSuccess()
    }
    
    func setupSubscriptions() {
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { item in
            if item !== self && item.redditPost.id == self.redditPost.id {
                try? self.favorited.onNext(item.favorited.value())
            }
        }).disposed(by: self.disposeBag)
    }
}

extension RedditViewItem: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        StorageService.shared.cacheVideoData(data: data, id: self.redditPost.id)
    }
    
    // func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {

    // }
    
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
