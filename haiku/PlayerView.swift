//
//  PlayerViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Player
import XCDYouTubeKit

class PlayerView: UIView, PlayerDelegate, PlayerPlaybackDelegate {
    
    var onReady: ((_ error: Bool) -> Void)?
    public var player: Player?
    public var redditPost: RedditPost?
    public var doneLoadingPlayer = false
    
    private var url: URL?
    private var id: String?
    
    let playerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let loadingIcon: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        return label
    }()
    
    var label: UILabel = UILabel()

    convenience init(_ id: String, redditPost: RedditPost) {
        self.init()
        self.backgroundColor = .white
        self.redditPost = redditPost
        self.id = id


        self.addTitle()
        self.initializePlayer()
    }
    
    func addTitle() {
        self.label.text = self.redditPost!.title
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
        }
    }
    
    func initializePlayer() {
        let player = Player()
        self.player = player
        self.player!.playerDelegate = self
        self.player!.playbackDelegate = self
        self.player!.playbackLoops = true
        self.player!.playbackResumesWhenBecameActive = false
        self.player!.playbackResumesWhenEnteringForeground = false
        self.player!.playbackFreezesAtEnd = true
        
        self.addSubview(self.playerContainer)
        self.playerContainer.isHidden = true
        self.addSubview(self.player!.view)
        
        self.playerContainer.snp.makeConstraints{(make) -> Void in
            make.width.equalTo(self)
            make.top.equalTo(self.player!.view)
            make.bottom.equalTo(self.player!.view)
        }
        self.setPlayerUrl(self.id!)
        self.addLoadingIcon()
    }
    
    func resetPlayer() {
        self.player?.view.removeFromSuperview()
        self.player = nil
        self.playerContainer.removeFromSuperview()
        self.doneLoadingPlayer = false
    }

    private func addLoadingIcon() {
        self.addSubview(self.loadingIcon)
        self.loadingIcon.snp.makeConstraints{(make) -> Void in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    private func removeLoadingIcon() {
        self.loadingIcon.removeFromSuperview()
    }

    func setPlayerUrl(_ id: String) {
        if (self.url != nil) {
            self.player?.url = url
            return
        }
        let client = XCDYouTubeClient.default()
        client.getVideoWithIdentifier(id) { (info, err) -> Void in
            if err == nil {
                let url = info?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                    ?? info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                    ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]
                if (url == nil) {
                    self.playerError()
                } else {
                    self.url = url
                    self.player?.url = url
                }
            } else {
                self.playerError()
            }
        }
    }

    func getMaxHeight() -> CGFloat {
        let width = UIScreen.main.bounds.width
        return (width * 9 / 16)
    }

    public func getTotalViewHeight() -> CGFloat {
        let labelHeightWithPadding = self.label.frame.height + 5
        let spaceBetweenRows = CGFloat(50)
        return self.getVideoHeight()
            + labelHeightWithPadding
            + spaceBetweenRows
    }
    
    // returns aspect height based on width
    private func getVideoHeight() -> CGFloat {
        if (self.player?.url != nil && self.player!.naturalSize.height > 0) {
            let newHeight = UIScreen.main.bounds.width * self.player!.naturalSize.height / self.player!.naturalSize.width
            let maxHeight = self.getMaxHeight()
            return newHeight > maxHeight ? maxHeight : newHeight
        } else {
            return self.getMaxHeight();
        }
    }
    
    public func togglePlaying() {
        self.player?.playbackState == .paused ? self.player?.playFromCurrentTime() : self.player?.pause()
    }

    func playerError() {
        self.loadingIcon.text = "Error loading video"
        self.doneLoadingPlayer = true
        self.onReady?(true)
    }
    
    // set contstraints after player is ready
    func playerReady(_ player: Player) {
        self.player?.view.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.label.snp.bottom).offset(5)
            make.width.equalTo(self)
            make.height.equalTo(self.getVideoHeight())
        }
        
        self.removeLoadingIcon()
        self.playerContainer.isHidden = false
        self.doneLoadingPlayer = true
        self.onReady?(false)
    }

    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
    }
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }
    
}

