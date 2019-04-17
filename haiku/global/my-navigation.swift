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
    let rootViewController = UIApplication.shared.keyWindow!.rootViewController
    
    func presentWebView(url: URL) {
        let webview = SFSafariViewController(url: url)
        self.rootViewController?.present(webview, animated: true)
    }

    func presentVideoPlayer(redditViewItem: RedditViewItem) {
        _ = redditViewItem.getPlayerItem.subscribe(onNext: { item in
            if let itemCopy: AVPlayerItem = item?.copy() as? AVPlayerItem {
                let player = AVPlayer(playerItem: itemCopy)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.rootViewController?.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        })
    }
}
