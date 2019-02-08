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
    var timeObserverToken: Any?
    
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
        self.activeRedditViewItem.onNext(redditViewItem)
        self.player.replaceCurrentItem(with: item)

        // if player time is set to 0 - check if we need to seek to start time from youtube URL
        if item.currentTime().value == 0 {
            self.player.seek(to: CMTime(seconds: Double(redditViewItem.videoStartTime), preferredTimescale: 1))
        }

        self.play()
    }
    
    /// seek to either 0 or time specified in youtube URL
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.pause()
        let time = (try? self.activeRedditViewItem.value()?.videoStartTime)! ?? 0
        self.player.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1))
    }

    func pause() {
//        self.stopTimeObserver()
        self.player.pause()
        self.playing = false
    }
    
    func play() {
        self.player.play()
        self.playing = true
//        self.startTimeObserver()
    }
    
    private func togglePlaying() {
        self.playing ? self.pause() : self.play()
    }
    
    private func intervalTick(_ time: CMTime) {
        if let duration = self.player.currentItem?.asset.duration.seconds {
            let percent = (time.seconds / duration)
            try? self.activeRedditViewItem.value()?.playerProgress.onNext(percent)
        }
    }
    
    func startTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.01, preferredTimescale: timeScale)
        self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.intervalTick(time)
        }
    }
    
    func stopTimeObserver() {
        if let observer = self.timeObserverToken {
            player.removeTimeObserver(observer)
            self.timeObserverToken = nil
        }
    }
    
    /// check if item is active in the player
    /// compares object reference to current active item
    func isActivePlayerItem(item: RedditViewItem) -> Bool {
        let i = try? self.activeRedditViewItem.value()
        return i != nil && i! === item
    }
}
