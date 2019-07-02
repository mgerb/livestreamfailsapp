//
//  RedditAlertController.swift
//  haiku
//
//  Created by Mitchell Gerber on 12/22/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

protocol RedditAlertControllerDelegate {
    func didHideItem(redditViewItem: RedditViewItem)
}

/// action sheet controller for when user presses more button
class RedditAlertController: UIAlertController {

    public var delegate: RedditAlertControllerDelegate?
    
    convenience init(redditViewItem: RedditViewItem) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let upvote = UIAlertAction(title: "Upvote", style: .default) { (action:UIAlertAction) in
            redditViewItem.upvote()
        }
        
        let downvote = UIAlertAction(title: "Downvote", style: .default) { (action:UIAlertAction) in
            redditViewItem.downvote()
        }
        
        let reportClipUrl = UIAlertAction(title: "Report", style: .destructive) { (action:UIAlertAction) in
            guard let url = URL(string: self.getRedditLink(permaLink: redditViewItem.redditLink.permalink)) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let hideClipAction = UIAlertAction(title: "Don't show me this post again", style: .destructive) { (action:UIAlertAction) in
            StorageService.shared.storeHiddenPost(redditLink: redditViewItem.redditLink)
            self.delegate?.didHideItem(redditViewItem: redditViewItem)
        }
        
//        let openClipUrl = UIAlertAction(title: "Open Direct Link", style: .default) { (action:UIAlertAction) in
//            guard let urlString = redditViewItem.redditLink.url, let url = URL(string: urlString) else { return }
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        
        let copyClipUrl = UIAlertAction(title: "Copy Direct Link", style: .default) { (action:UIAlertAction) in
            UIPasteboard.general.string = redditViewItem.redditLink.url
        }
        
//        let openInReddit = UIAlertAction(title: "Open Reddit Link", style: .default) { (action:UIAlertAction) in
//            guard let url = URL(string: self.getRedditLink(permaLink: redditViewItem.redditLink.permalink)) else { return }
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        
        let copyRedditLink = UIAlertAction(title: "Copy Reddit Link", style: .default) { (action:UIAlertAction) in
            UIPasteboard.general.string = self.getRedditLink(permaLink: redditViewItem.redditLink.permalink)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        
        self.addAction(upvote)
        self.addAction(downvote)
//        self.addAction(openClipUrl)
        self.addAction(copyClipUrl)
//        self.addAction(openInReddit)
        self.addAction(copyRedditLink)
        self.addAction(cancel)
        self.addAction(reportClipUrl)
        if redditViewItem.context != .favorites {
            self.addAction(hideClipAction)
        }
    }
    
    private func getRedditLink(permaLink: String) -> String {
        return "https://www.reddit.com\(permaLink)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

