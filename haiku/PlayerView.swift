//
//  PlayerViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Player

class PlayerView: UIView, PlayerDelegate, PlayerPlaybackDelegate {
    
    var isReady: (() -> Void)?
    public var player: Player!

    convenience init(player: Player) {
        self.init()
        self.player = player
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        
        self.player.playbackLoops = true
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackResumesWhenEnteringForeground = false
        self.player.playbackFreezesAtEnd = true
        
        self.backgroundColor = .white
        self.addSubview(self.player.view)
        
        // constraints
        self.player.view.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self)
        }
    }

    // returns aspect height based on width
    public func getHeight(_ width: CGFloat) -> CGFloat {
        return width * self.player.naturalSize.height / self.player.naturalSize.width
    }
    
    public func togglePlaying() {
        self.player.playbackState == .paused ? self.player.playFromCurrentTime() : self.player.pause()
    }

    func playerReady(_ player: Player) {
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

