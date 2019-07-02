//
//  MyNavigation.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import SafariServices

class MyNavigation {
    public static let shared = MyNavigation()
    let rootViewController = {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    func presentWebView(url: URL) {
        let webview = SFSafariViewController(url: url)
        self.rootViewController()?.present(webview, animated: true)
    }

    func presentVideoPlayer(redditViewItem: RedditViewItem) {
        _ = redditViewItem.getPlayerItem.subscribe(onNext: { item in
            if let itemCopy: AVPlayerItem = item?.copy() as? AVPlayerItem {
                GlobalPlayer.shared.pause()
                let player = AVPlayer(playerItem: itemCopy)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.rootViewController()?.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        })
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.rootViewController()?.present(alert, animated: true)
    }
    
    func presetLoginAlert() {
        self.presentAlert(title: nil, message: "Please login to vote")
    }
}
