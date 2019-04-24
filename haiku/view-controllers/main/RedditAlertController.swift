//
//  RedditAlertController.swift
//  haiku
//
//  Created by Mitchell Gerber on 12/22/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

/// action sheet controller for when user presses more button
class RedditAlertController: UIAlertController {

    convenience init(redditViewItem: RedditViewItem) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let openClipUrl = UIAlertAction(title: "Open Clip Link", style: .default) { (action:UIAlertAction) in
            guard let urlString = redditViewItem.redditLink.url, let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let copyClipUrl = UIAlertAction(title: "Copy Clip Link", style: .default) { (action:UIAlertAction) in
            UIPasteboard.general.string = redditViewItem.redditLink.url
        }
        
        let openInReddit = UIAlertAction(title: "Open Reddit Link", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: self.getRedditLink(permaLink: redditViewItem.redditLink.permalink)) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let copyRedditLink = UIAlertAction(title: "Copy Reddit Link", style: .default) { (action:UIAlertAction) in
            UIPasteboard.general.string = self.getRedditLink(permaLink: redditViewItem.redditLink.permalink)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        
        self.addAction(openClipUrl)
        self.addAction(copyClipUrl)
        self.addAction(openInReddit)
        self.addAction(copyRedditLink)
        self.addAction(cancel)
    }
    
    private func getRedditLink(permaLink: String) -> String {
        return "https://www.reddit.com\(permaLink)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

