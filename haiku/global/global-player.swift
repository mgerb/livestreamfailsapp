//
//  global-player.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import AVKit
import AVFoundation
import RxSwift

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
    var activeRedditViewItem = BehaviorSubject<RedditViewItem?>(value: nil)
    
    func replaceItem(_ item: AVPlayerItem, _ redditViewItem: RedditViewItem) {
        // toggle player if trying to set current active player item
        if item === self.player.currentItem {
            self.togglePlaying()
            return
        }
        self.pause()
        self.player.replaceCurrentItem(with: item)
        self.activeRedditViewItem.onNext(redditViewItem)
        self.player.play()
        self.playing = true
    }
    
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
    
    func togglePlaying() {
        if self.playing {
            self.pause()
            self.playing = false
        } else {
            self.play()
            self.playing = true
        }
    }
    
    /// check if item is currently playing
    /// compares object reference to current active item
    func isItemPlaying(item: RedditViewItem) -> Bool {
        let i = try? self.activeRedditViewItem.value()
        return i != nil && i! === item
    }
}
