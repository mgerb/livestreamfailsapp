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
        
        let action1 = UIAlertAction(title: "Copy Video URL", style: .default) { (action:UIAlertAction) in
            UIPasteboard.general.string = redditViewItem.redditPost.url
        }
        
        let action2 = UIAlertAction(title: "Open in Reddit", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: "https://www.reddit.com\(redditViewItem.redditPost.permalink)") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        
        self.addAction(action1)
        self.addAction(action2)
        self.addAction(action3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

