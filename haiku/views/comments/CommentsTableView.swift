//
//  CommentsTableView.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/12/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsTableView: TapThroughTableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var didLoad = false
    var data: [Any] = ["loading"]
    private let footerHeight: CGFloat = 400
    let redditViewItem: RedditViewItem
    
    init(frame: CGRect, redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        super.init(frame: frame, style: .grouped)

        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        
        self.contentInset.top = self.frame.height

        self.register(CommentViewCell.self, forCellReuseIdentifier: "CommentViewCell")
        self.register(UITableViewCell.self, forCellReuseIdentifier: "LoadingCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.contentOffset.y = -(self.frame.height / 2)
                }, completion: {_ in
                    self.contentInset.bottom = -self.footerHeight
                    self.fetchComments()
                })
            }
        }
    }

    func fetchComments () {
        RedditService.shared.getFlattenedComments(permalink: self.redditViewItem.redditPost.permalink) {comments in
            if comments.count > 0 {
                self.data = comments
                self.reloadData()
                DispatchQueue.main.async {
                    self.contentOffset.y = -(self.frame.height / 2)
                    self.didLoad = true
                }
            }
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.setContentOffset(CGPoint(x: 0, y: -self.frame.height), animated: false)
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.data[indexPath.row] as? String == "loading" {
            return 300
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comment = self.data[indexPath.row] as? RedditComment {
            let cell = self.dequeueReusableCell(withIdentifier: "CommentViewCell", for: indexPath) as! CommentViewCell
            cell.setRedditComment(c: comment)
            return cell
        } else {
            let cell = self.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            cell.textLabel?.text = "Loading..."
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewCell()
        view.backgroundColor = .white
        view.textLabel?.text = "Comments"
        view.textLabel?.textAlignment = .center
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.didLoad && self.contentOffset.y < -(self.frame.height) {
            self.removeFromSuperview()
        }
    }
}
