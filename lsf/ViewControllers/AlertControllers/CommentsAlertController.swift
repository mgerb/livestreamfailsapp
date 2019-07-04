//
//  CommentsAlertController.swift
//  lsf
//
//  Created by Mitchell Gerber on 6/30/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit

protocol CommentsAlertDelegate {
    func commentAdded(parent: RedditComment, comment: RedditComment)
    func commentDeleted(comment: RedditComment)
}

class CommentsAlertController: UIAlertController {
    
    var delegate: CommentsAlertDelegate?
    
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
        
        let reply = UIAlertAction(title: "Reply", style: .default) { action in
            if !RedditService.shared.isLoggedIn() {
                MyNavigation.shared.presetLoginAlert()
                return
            }
            let commentsReplyViewController = CommentsReplyViewController()
            commentsReplyViewController.setRedditComment(comment: comment)
            commentsReplyViewController.success = { newComment in
                self.delegate?.commentAdded(parent: comment, comment: newComment)
            }
            let navController = UINavigationController(rootViewController: commentsReplyViewController)
            navController.modalTransitionStyle = .coverVertical
            MyNavigation.shared.rootViewController()?.present(navController, animated: true, completion: nil)
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            RedditService.shared.delete(name: comment.name, completion: { success in
                if success {
                    self.delegate?.commentDeleted(comment: comment)
                }
            })
        }

        self.addAction(upvote)
        self.addAction(downvote)
        self.addAction(reply)
        self.addAction(permalink)
        self.addAction(copypermalink)
        if comment.author == RedditService.shared.user?.name {
            self.addAction(delete)
        }
        self.addAction(cancel)
    }
}
