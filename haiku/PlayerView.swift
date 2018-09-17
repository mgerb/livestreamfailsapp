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
        view.backgroundColor = .black
        return view
    }()

    convenience init(_ id: String) {
        self.init()
        self.backgroundColor = .white
        self.addSubview(self.playerContainer)

        let player = Player()
        self.player = player
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        self.player.playbackLoops = true
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackResumesWhenEnteringForeground = false
        self.player.playbackFreezesAtEnd = true

        self.addSubview(self.player.view)


        self.initializePlayer(id)
    }

    func initializePlayer(_ id: String) {
        let client = XCDYouTubeClient.default()
        client.getVideoWithIdentifier(id) { (info, err) -> Void in
            self.player.url = info?.streamURLs[22]
        }
    }

    // returns aspect height based on width
    public func getHeight(_ width: CGFloat) -> CGFloat {
        if (self.player.naturalSize.height > 0) {
            let newHeight = width * self.player.naturalSize.height / self.player.naturalSize.width
            let maxHeight = (width * 9 / 16)
            return newHeight > maxHeight ? maxHeight : newHeight
        } else {
            return 0;
        }
    }
    
    public func togglePlaying() {
        self.player.playbackState == .paused ? self.player.playFromCurrentTime() : self.player.pause()
    }

    // set contstraints after player is ready
    func playerReady(_ player: Player) {
        self.playerContainer.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self)
            make.height.equalTo(self.getHeight(self.frame.width))
        }
        self.player.view.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(self)
            make.height.equalTo(self.playerContainer)
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

