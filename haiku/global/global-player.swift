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
        // let timeScale = CMTimeScale(NSEC_PER_SEC)
        // let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        // let timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
        //     self?.intervalTick()
        // }
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
        self.play()
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
    
    private func togglePlaying() {
        self.playing ? self.pause() : self.play()
    }
    
    private func intervalTick() {
        if let duration = self.player.currentItem?.asset.duration.seconds {
            let percent = (self.player.currentTime().seconds / duration)
            print(percent)
//            try? self.activeRedditViewItem.value()?.playerProgress.onNext(percent)
        }
    }
    
    /// check if item is active in the player
    /// compares object reference to current active item
    func isActivePlayerItem(item: RedditViewItem) -> Bool {
        let i = try? self.activeRedditViewItem.value()
        return i != nil && i! === item
    }
}
