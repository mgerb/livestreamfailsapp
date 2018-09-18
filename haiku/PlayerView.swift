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
    
    var isReady: (() -> Void)?
    public var player: Player!
    public var redditPost: RedditPost?
    
    let playerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    var label: UILabel = UILabel()

    convenience init(_ id: String, redditPost: RedditPost) {
        self.init()
        self.backgroundColor = .white
        self.redditPost = redditPost
//        self.addSubview(self.playerContainer)

        let player = Player()
        self.player = player
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        self.player.playbackLoops = true
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackResumesWhenEnteringForeground = false
        self.player.playbackFreezesAtEnd = true

        self.addSubview(self.player.view)
        
        self.label.text = self.redditPost!.title
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
        }

        self.initializePlayer(id)
    }

    func initializePlayer(_ id: String) {
        let client = XCDYouTubeClient.default()
        client.getVideoWithIdentifier(id) { (info, err) -> Void in
            self.player.url = info?.streamURLs[22]
        }
    }

    func getMaxHeight() -> CGFloat {
        let width = UIScreen.main.bounds.width
        return (width * 9 / 16)
    }

    // returns aspect height based on width
    public func getVideoHeight() -> CGFloat {
        if (self.player.url != nil && self.player.naturalSize.height > 0) {
            let newHeight = UIScreen.main.bounds.width * self.player.naturalSize.height / self.player.naturalSize.width
            let maxHeight = self.getMaxHeight()
            return newHeight > maxHeight ? maxHeight : newHeight
        } else {
            return self.getMaxHeight();
        }
    }
    
    public func togglePlaying() {
        self.player.playbackState == .paused ? self.player.playFromCurrentTime() : self.player.pause()
    }

    // set contstraints after player is ready
    func playerReady(_ player: Player) {
//        self.playerContainer.snp.makeConstraints { (make) -> Void in
//            make.width.equalTo(self)
//            make.height.equalTo(self.getVideoHeight())
//        }
        self.player.view.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.label.snp.bottom).offset(5)
            make.width.equalTo(self)
//            make.height.equalTo(self.playerContainer)
            make.height.equalTo(self.getVideoHeight())
        }
        
        self.isReady?()
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

