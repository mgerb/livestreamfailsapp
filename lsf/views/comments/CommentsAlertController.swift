//
//  CommentsAlertController.swift
//  lsf
//
//  Created by Mitchell Gerber on 6/30/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit

class CommentsAlertController: UIAlertController {
    
    convenience init(comment: RedditComment) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let upvote = UIAlertAction(title: "Upvote", style: .default) { (action:UIAlertAction) in
            if !RedditService.shared.isLoggedIn() {
                MyNavigation.shared.presetLoginAlert()
            } else {
                comment.likes = comment.likes != true ? true : nil
                RedditService.shared.vote(id: comment.name, dir: comment.likes == true ? 1 : 0, completion: { success in
                })
            }
        }
        
        let downvote = UIAlertAction(title: "Downvote", style: .default) { (action:UIAlertAction) in
            if !RedditService.shared.isLoggedIn() {
                MyNavigation.shared.presetLoginAlert()
            } else {
                comment.likes = comment.likes != false ? false : nil
                RedditService.shared.vote(id: comment.name, dir: comment.likes == false ? -1 : 0, completion: { success in
                })
            }
        }
        
        let permalink = UIAlertAction(title: "Permalink", style: .default) { action in
            if let url = comment.getPermalink() {
                MyNavigation.shared.presentWebView(url: url)
            }
        }
        
        let copypermalink = UIAlertAction(title: "Copy Permalink", style: .default) { action in
            if let url = comment.getPermalink() {
                UIPasteboard.general.string = url.absoluteString
            }
        }
        
        self.addAction(cancel)
        self.addAction(upvote)
        self.addAction(downvote)
        self.addAction(permalink)
        self.addAction(copypermalink)
    }
}
