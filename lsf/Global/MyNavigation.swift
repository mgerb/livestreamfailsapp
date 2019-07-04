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
    private var alertController: UIAlertController?
    
    let rootViewController = {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    let topViewController = {
        return UIApplication.topViewController()
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
        self.hideAlert {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.topViewController()?.present(alert, animated: true)
        }
    }
    
    func presetLoginAlert() {
        self.presentAlert(title: nil, message: "Please login to use this feature.")
    }

    func showLoadingAlert() {
        self.hideAlert {
            self.alertController = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            self.alertController!.view.addSubview(loadingIndicator)
            self.topViewController()?.present(self.alertController!, animated: true, completion: nil)
        }
    }
    
    func hideAlert(completion: @escaping () -> Void) {
        if let controller = self.alertController {
            controller.dismiss(animated: true, completion: {
                self.alertController = nil
                completion()
            })
        } else {
            completion()
        }
    }
}
