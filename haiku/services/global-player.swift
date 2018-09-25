//
//  global-player.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import AVKit
import AVFoundation

/**
 * Keep state of current playing video because only one can play at a time
 */
class GlobalPlayer {
    static let shared = GlobalPlayer()
    var player: AVPlayer?
    var playing = false

    func onPlayerTap(_ p: AVPlayer) {
        if self.player === p {
            self.playing ? self.pause() : self.play()
        } else {
            self.pause()
            self.initNewPlayer(p)
            self.play()
        }
    }
    
    func initNewPlayer(_ p: AVPlayer) {
        self.player = p
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: p.currentItem)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pause()
        self.player?.seek(to: CMTime(seconds: Double(0), preferredTimescale: 1))
    }

    func pause() {
        self.player?.pause()
        self.playing = false
    }
    
    func play() {
        self.player?.play()
        self.playing = true
    }
}
