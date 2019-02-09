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
        self.getThumbnailImage() { image in
            view.image = image
        }
        return view
    }()
    private var cachedPlayerItem: CachingPlayerItem? = nil
    private var cachedVideoUrl: URL?
    private var cachedThumbnailUrl: URL?
    
    lazy var humanTimeStampExtended: String = {
        return Date().offsetExtended(from: Date(timeIntervalSince1970: TimeInterval(Int(self.redditPost.created_utc))))
    }()

    init(_ redditPost: RedditPost, context: RedditViewItemContext) {
        self.redditPost = redditPost
        self.context = context
        self.setupSubscriptions()
    }
    
    // return videoUrl and thumbnailUrl and cache them on object
    private func getClipUrlInfo() -> Observable<(URL?, URL?)> {
        return Observable.create { observer in
            
            // return cached url's if they exist
            if let videoUrl = self.cachedVideoUrl, let thumbnailUrl = self.cachedThumbnailUrl {
                observer.onNext((videoUrl, thumbnailUrl))
                observer.onCompleted()
            } else {
                ClipUrlService.shared.getClipInfo(redditPost: self.redditPost) { (videoUrl, thumbnailUrl) in
                    self.cachedVideoUrl = videoUrl
                    self.cachedThumbnailUrl = thumbnailUrl
                    observer.onNext((videoUrl, thumbnailUrl))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }.share()
    }
    
    func getPlayerItem() -> Observable<(CachingPlayerItem?, URL?)> {
        return Observable.create { observer in

            let dispose = Disposables.create()
            
            DispatchQueue.global().async {
                let dispatchGroup = DispatchGroup()
    
                if self.cachedPlayerItem == nil {
                    var item: CachingPlayerItem?
                    
                    // first try to grab from cached disk storage
                    dispatchGroup.enter()
                    StorageService.shared.getCachedVideo(id: self.redditPost.id) { res in
                        if let storedItemData = res {
                            item = CachingPlayerItem(data: storedItemData, mimeType: "video/mp4", fileExtension: "mp4")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.wait()
                    
                    // if still nil try to fetch item
                    if item == nil {
                        dispatchGroup.enter()
                        self.getClipUrlInfo().subscribe(onNext: { (videoUrl, thumbnailUrl) in
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
                    observer.onNext((self.cachedPlayerItem, nil))
                    observer.onCompleted()
                }
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
    
    func getThumbnailImage(closure: @escaping (_ image: UIImage?) -> Void) {
        
        DispatchQueue.global().async {
            
            let dispatchGroup = DispatchGroup()
            var data: Data?

            dispatchGroup.enter()
            // check storage for image first
            StorageService.shared.getCachedImage(id: self.redditPost.id) { res in
                data = res
                dispatchGroup.leave()
            }
            
            if let d = data {
                DispatchQueue.main.async {
                    closure(UIImage(data: d))
                }
                return
            }
            
            dispatchGroup.wait()
            
            if data == nil {
                if let youtubeID = self.redditPost.url?.youtubeID {
                    data = try? Data(contentsOf: URL(string: "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg")!)
                }
            }
                
            if data == nil {
                dispatchGroup.enter()
                self.getClipUrlInfo().subscribe(onNext: { (_, thumbnailUrl) in
                    if let thumbnailUrl = thumbnailUrl {
                        // TODO: change this and use alamofire - this causes table view lag I think
                        data = try? Data(contentsOf: thumbnailUrl)
                    }
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.wait()

            if let data = data {
                StorageService.shared.cacheImage(data: data, id: self.redditPost.id)
            }
            
            let image: UIImage? = data != nil ? UIImage(data: data!) : nil
            
            DispatchQueue.main.async {
                closure(image)
            }
        }
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
        StorageService.shared.cacheVideo(data: data, id: self.redditPost.id)
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
