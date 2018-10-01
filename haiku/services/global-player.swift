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
class GlobalPlayer: NSObject {
    static let shared = GlobalPlayer()
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        return player
    }()
    var playing = false

    func replaceItem(_ item: AVPlayerItem) {
        self.pause()
        self.player.replaceCurrentItem(with: item)
        self.player.play()
    }
    
//    func onPlayerTap(_ p: AVPlayer) {
//        if self.player === p {
//            self.playing ? self.pause() : self.play()
//        } else {
//            self.pause()
//            self.initNewPlayer(p)
//            self.play()
//        }
//    }
//

    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pause()
        self.player.seek(to: CMTime(seconds: Double(0), preferredTimescale: 1))
    }

    func pause() {
        self.player.pause()
        self.playing = false
    }
    
    func play() {
        self.player.play()
        self.playing = true
    }
}
