//
//  PlayerViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Player

class PlayerView: UIView, PlayerDelegate, PlayerPlaybackDelegate {
    
    public var player: Player!

    public func initView(_ player: Player) {
        self.player = player
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        
        self.player.playbackLoops = true
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackFreezesAtEnd = true
        
        self.addSubview(self.player.view)

        // constraints
        self.player.view.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self)
        }
    }
    
    public func togglePlaying() {
        self.player.playbackState == .paused ? self.player.playFromCurrentTime() : self.player.pause()
    }
    
    func playerReady(_ player: Player) {
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

