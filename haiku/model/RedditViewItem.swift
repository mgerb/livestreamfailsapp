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

enum RedditViewItemPlayerState {
    case idle
    case loading
    case error
}

enum RedditViewItemVideoType {
    case youtube
    case twitch
    case neatclip
    case livestreamfails
    case streamable
    case other
}

class RedditViewItem {
    let redditPost: RedditPost
    let disposeBag = DisposeBag()
    let videoType: RedditViewItemVideoType
    
    /// context of where item is being used - either home or favorites page
    var context: RedditViewItemContext
    
    lazy var favorited = BehaviorSubject<Bool>(value: StorageService.shared.redditPostFavoriteExists(id: self.redditPost.id))
    lazy var markedAsWatched = BehaviorSubject<Bool>(value: StorageService.shared.getWatchedRedditPost(redditPost: self.redditPost))
    /// TODO: what state the player is in
    lazy var playerState = BehaviorSubject<RedditViewItemPlayerState>(value: .idle)
    lazy var playerProgress = BehaviorSubject<Double>(value: 0.0)
    
    /// if XCDYouTubeKit fails to load the video
    var unavailable = false

    lazy var videoStartTime: Int = self.redditPost.url?.youtubeStartTime ?? 0
    lazy var videoEndTime: Int? = self.redditPost.url?.youtubeEndTime

    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        if let youtubeID = self.redditPost.url?.youtubeID {
            // cache thumbnail with KF
            view.kf.setImage(with: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
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

        // set video type based on the url
        var type: RedditViewItemVideoType
        let url = self.redditPost.url
        if url?.youtubeID != nil {
            type = .youtube
        }  else if url?.twitchID != nil {
            type = .twitch
        }  else if url?.liveStreamFails != nil {
            type = .livestreamfails
        }  else if url?.streamable != nil {
            type = .streamable
        } else if url?.neatclipID != nil {
            type = .neatclip
        } else {
            type = .other
        }
        
        self.videoType = type
        self.setupSubscriptions()
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
            
            // TODO:
            RedditService.shared.getFirstComment(permalink: self.redditPost.permalink) { comment in
                if let body = comment?.body {
                    if let streamable = body.streamable {
                        print(streamable)
                    }
                    if let livestreamfails = body.liveStreamFails {
                        print(livestreamfails)
                    }
                }
            }
            
            if let urlString = self.redditPost.url {
                ClipUrlService.shared.getClipUrl(url: urlString, urlType: self.videoType) {url in
                    if let url = url {
                        if urlString.hasSuffix("mp4") {
                            self.cachedPlayerItem = CachingPlayerItem(url: url)
                        } else {
                            self.cachedPlayerItem = CachingPlayerItem(url: url, customFileExtension: "mp4")
                        }
                        self.cachedPlayerItem?.delegate = self
                        observer.onNext(self.cachedPlayerItem)
                        observer.onCompleted()
                    } else {
                        observer.onCompleted()
                    }
                }
            } else {
                observer.onCompleted()
            }

            return dispose
        }.share()
    }

    func updateGlobalPlayer() {
        self.getPlayerItem().subscribe(onNext: { item in
            StorageService.shared.storeWatchedRedditPost(redditPost: self.redditPost)
            self.markedAsWatched.onNext(true)
            GlobalPlayer.shared.replaceItem(item!, self)
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
