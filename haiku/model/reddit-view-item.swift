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
import Alamofire
import DifferenceKit

enum RedditViewItemContext {
    case home
    case favorites
}

enum RedditViewItemPlayerState {
    case idle
    case loading
    case error
}

protocol RedditViewItemDelegate {
    func failedToLoadVideo(redditViewItem: RedditViewItem)
    func didMarkAsWatched(redditViewItem: RedditViewItem)
}

class RedditViewItem {
    
    // manage cached player items
    // only keep 5 cached at any one time otherwise memory fills up
    static var cacheManager: [RedditViewItem] = []
    
    let delegate = MulticastDelegate<RedditViewItemDelegate>()
    let redditLink: RedditLink
    let disposeBag = DisposeBag()

    /// context of where item is being used - either home or favorites page
    var context: RedditViewItemContext
    
    lazy var favorited = BehaviorSubject<Bool>(value: StorageService.shared.redditLinkFavoriteExists(id: self.redditLink.id))
    var markedAsWatched: Bool {
        didSet {
            self.delegate.invoke(invocation: { $0.didMarkAsWatched(redditViewItem: self) })
        }
    }
    lazy var playerProgress = BehaviorSubject<Double>(value: 0.0)

    lazy var videoStartTime: Int = self.redditLink.url?.youtubeStartTime ?? 0
    lazy var videoEndTime: Int? = self.redditLink.url?.youtubeEndTime
    
    var failedToLoadVideo = false {
        didSet {
            self.delegate.invoke(invocation: { $0.failedToLoadVideo(redditViewItem: self) })
        }
    }

    var thumbnail: UIImageView {
        let view = UIImageView()
        view.alpha = 0
        _ = self.getThumbnailImage.subscribe(onNext: { image, animate in
            view.image = image
            if animate {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { view.alpha = 1 }, completion: nil)
            } else {
                view.alpha = 1
            }
        })
        return view
    }

    lazy var humanTimeStampExtended: String = {
        return Date().offsetExtended(from: Date(timeIntervalSince1970: TimeInterval(Int(self.redditLink.created_utc))))
    }()

    lazy var humanTimeStamp: String = {
        return Date().offset(from: Date(timeIntervalSince1970: TimeInterval(Int(self.redditLink.created_utc))))
    }()
    
    private var cachedPlayerItem: CachingPlayerItem? = nil
    private var cachedVideoUrl: URL?
    private var cachedThumbnailUrl: URL?

    init(_ redditLink: RedditLink, context: RedditViewItemContext) {
        self.redditLink = redditLink
        self.context = context
        self.markedAsWatched = StorageService.shared.getWatchedRedditLink(redditLink: self.redditLink)
        self.setupSubscriptions()
    }
    
    // return videoUrl and thumbnailUrl and cache them on object
    lazy var getClipUrlInfo: Observable<(URL?, URL?)> = {
        return Observable.create { observer in
            
            if self.failedToLoadVideo {
                observer.onNext((nil, nil))
                observer.onCompleted()
            } else if let videoUrl = self.cachedVideoUrl, let thumbnailUrl = self.cachedThumbnailUrl {
                // return cached url's if they exist
                observer.onNext((videoUrl, thumbnailUrl))
                observer.onCompleted()
            } else {
                ClipUrlService.shared.getClipInfo(redditLink: self.redditLink) { (videoUrl, thumbnailUrl) in
                    self.cachedVideoUrl = videoUrl
                    self.cachedThumbnailUrl = thumbnailUrl
                    self.failedToLoadVideo = videoUrl == nil
                    observer.onNext((videoUrl, thumbnailUrl))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }.share()
    }()
    
    lazy var getPlayerItem: Observable<CachingPlayerItem?> = {
        return Observable.create { observer in

            let dispose = Disposables.create()
            
            DispatchQueue.global().async {
                let dispatchGroup = DispatchGroup()
    
                if self.cachedPlayerItem == nil {
                    var item: CachingPlayerItem?
                    
                    // first try to grab from cached disk storage
                    dispatchGroup.enter()
                    StorageService.shared.getCachedVideo(id: self.redditLink.id) { res in
                        if let storedItemData = res {
                            item = CachingPlayerItem(data: storedItemData, mimeType: "video/mp4", fileExtension: "mp4")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.wait()
                    
                    // if still nil try to fetch item
                    if item == nil {
                        dispatchGroup.enter()
                        _ = self.getClipUrlInfo.subscribe(onNext: { (videoUrl, thumbnailUrl) in
                            if let videoUrl = videoUrl {
                                if videoUrl.absoluteString.hasSuffix("mp4") == true {
                                    item = CachingPlayerItem(url: videoUrl)
                                } else {
                                    item = CachingPlayerItem(url: videoUrl, customFileExtension: "mp4")
                                }
                            }
                            dispatchGroup.leave()
                        })
                    }
                    
                    dispatchGroup.wait()
                    self.cachedPlayerItem = item
                    self.cachedPlayerItem?.delegate = self
                }
    
                dispatchGroup.wait()
                
                DispatchQueue.main.async {
                    observer.onNext(self.cachedPlayerItem)
                    observer.onCompleted()
                }
            }

            return dispose
        }.share()
    }()

    func updateGlobalPlayer() -> Observable<Void> {
        return self.getPlayerItem.map { item in
            if let item = item {
                self.manageVideoCache()
                StorageService.shared.storeWatchedRedditLink(redditLink: self.redditLink)
                self.markedAsWatched = true
                GlobalPlayer.shared.replaceItem(item, self)
            }
        }
    }
    
    lazy var getThumbnailImage: Observable<(UIImage?, Bool)> = {
        
        return Observable.create { observer in
            DispatchQueue.global().async {
                
                let dispatchGroup = DispatchGroup()
                var data: Data?
                
                dispatchGroup.enter()
                // check storage for image first
                StorageService.shared.getCachedImage(id: self.redditLink.id) { res in
                    data = res
                    dispatchGroup.leave()
                }
                
                dispatchGroup.wait()
                
                if let d = data {
                    DispatchQueue.main.async {
                        observer.onNext((UIImage(data: d), false))
                        observer.onCompleted()
                    }
                    return
                }
                
                dispatchGroup.wait()
                
                if data == nil {
                    if let youtubeID = self.redditLink.url?.youtubeID {
                        data = try? Data(contentsOf: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
                    }
                }
                
                if data == nil {
                    dispatchGroup.enter()
                    _ = self.getClipUrlInfo.subscribe(onNext: { (_, thumbnailUrl) in
                        if let thumbnailUrl = thumbnailUrl {
                            dispatchGroup.enter()
                            let queue = DispatchQueue(label: "RedditViewItem.getThumbnailImage", qos: .utility, attributes: [.concurrent])
                            Alamofire.request(thumbnailUrl).validate()
                                .response(queue: queue, responseSerializer: DataRequest.dataResponseSerializer(), completionHandler: { res in
                                    switch res.result {
                                    case .success(let d):
                                        data = d
                                    case .failure(let err):
                                        print(err)
                                    }
                                    dispatchGroup.leave()
                                })
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.wait()
                
                if let data = data {
                    StorageService.shared.cacheImage(data: data, id: self.redditLink.id)
                }
                
                let image: UIImage? = data != nil ? UIImage(data: data!) : nil
                
                DispatchQueue.main.async {
                    // animate after network call because it took some time to load
                    observer.onNext((image, true))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }.share()
    }()
    
    func manageVideoCache() {
        if !RedditViewItem.cacheManager.contains(where: { $0.redditLink.id == self.redditLink.id }) {
            if RedditViewItem.cacheManager.count >= 5 {
                let item = RedditViewItem.cacheManager.removeLast()
                item.cachedPlayerItem = nil
            }
            RedditViewItem.cacheManager.insert(self, at: 0)
        }
    }
    
    func toggleFavorite() {
        if try! self.favorited.value() {
            self.favorited.onNext(false)
            StorageService.shared.deleteRedditLinkFavorite(id: self.redditLink.id)
            // pause player if removing playing video from favorites
            if GlobalPlayer.shared.isActivePlayerItem(item: self) && self.context == .favorites {
                GlobalPlayer.shared.pause()
            }
        } else {
            self.favorited.onNext(true)
            StorageService.shared.storeRedditLinkFavorite(redditLink: self.redditLink)
        }
        Subjects.shared.favoriteButtonAction.onNext(self)
        Util.hapticFeedbackSuccess()
    }
    
    func setupSubscriptions() {
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { item in
            if item !== self && item.redditLink.id == self.redditLink.id {
                try? self.favorited.onNext(item.favorited.value())
            }
        }).disposed(by: self.disposeBag)
    }
    
    /// returns title with extra spaces if nsfw
    func getTitleLabelText() -> String {
        var title = self.redditLink.title.replaceEncoding()
        if self.redditLink.over_18 {
            title = "            " + title
        }
        return title
    }
}

extension RedditViewItem: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        if UserSettings.shared.cacheVideos {
            StorageService.shared.cacheVideo(data: data, id: self.redditLink.id)
        }
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

extension RedditViewItem: ListDiffable, Differentiable {
    static func == (lhs: RedditViewItem, rhs: RedditViewItem) -> Bool {
        return true
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.redditLink.id as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? RedditViewItem {
            return self.redditLink.id == object.redditLink.id
        }
        return false
    }
    
    var differenceIdentifier: String {
        return self.redditLink.id
    }
    
    func isContentEqual(to source: RedditViewItem) -> Bool {
        return self.redditLink.id == source.redditLink.id
    }
}
