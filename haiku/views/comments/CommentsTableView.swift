//
//  CommentsTableView.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/12/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CommentsTableView: TapThroughTableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var didLoad = false
    var didFinishInitialAnimation = false
    var data: [Any] = ["loading"]
    private let footerHeight: CGFloat = 600
    let redditViewItem: RedditViewItem
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.addSubview(self.whiteBackgroundLayer)
        return view
    }()
    
    lazy var whiteBackgroundLayer: UIView = {
        let view = UIView()
        view.backgroundColor = Config.colors.bg1
        return view
    }()
    
    init(frame: CGRect, redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        super.init(frame: frame, style: .grouped)

        self.separatorStyle = .none
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        self.estimatedRowHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionFooterHeight = 0
        
        self.backgroundView = self.bgView

        self.contentInset.top = self.frame.height

        self.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        self.register(CommentsViewCellContent.self, forCellReuseIdentifier: "CommentsViewCellContent")
        self.register(CommentsViewCellMore.self, forCellReuseIdentifier: "CommentsViewCellMore")
        self.register(CommentsLoadingCell.self, forCellReuseIdentifier: "CommentsLoadingCell")
        self.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "FooterCell")
        self.register(CommentsHeaderCell.self, forHeaderFooterViewReuseIdentifier: "HeaderCell")
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
                    DispatchQueue.main.async {
                        self.didFinishInitialAnimation = true
                        self.setWhiteBackgroundLayout()
                        self.contentInset.bottom = -(self.footerHeight - 100)
                    }
                    self.fetchComments()
                })
            }
        }
    }

    func fetchComments () {
        RedditService.shared.getFlattenedComments(permalink: self.redditViewItem.redditPost.permalink) {comments in
            self.data = comments.count > 0 ? comments : ["no comments"]
            self.didLoad = true
            self.reloadData()
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

    // height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.data[indexPath.row] {
        case let s as String:
            if s == "loading" || s == "no comments" {
                return 300
            }
        case let comment as RedditComment:
            if comment.isHidden {
                return 0
            } else if comment.isMoreComment || comment.isContinueThread {
                return 30
            } else if comment.isCollapsed || comment.isDeleted {
                return 40
            } else {
                return CommentsViewCellContent.getHeight(redditComment: comment)
            }
        default:
            return 50
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comment = self.data[indexPath.row] as? RedditComment {
            
            // return empty cell if hidden - improves performance tremendously
            if comment.isHidden {
                return self.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            } else if comment.isMoreComment || comment.isContinueThread {
                let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellMore", for: indexPath) as! CommentsViewCellMore
                cell.setRedditComment(c: comment)
                return cell
            } else {
                let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellContent", for: indexPath) as! CommentsViewCellContent
                cell.setRedditComment(c: comment)
                return cell
            }
            
        } else if let c = self.data[indexPath.row] as? String {
            let cell = self.dequeueReusableCell(withIdentifier: "CommentsLoadingCell", for: indexPath) as! CommentsLoadingCell
            c == "loading" ? cell.setLoading() : cell.setNoComments()
            return cell
        } else {
            return self.dequeueReusableCell(withIdentifier: "CommentsLoadingCell", for: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCell")
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = self.dequeueReusableHeaderFooterView(withIdentifier: "FooterCell")
        cell?.backgroundColor = Config.colors.bg1
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.didFinishInitialAnimation {
            self.setWhiteBackgroundLayout()
        }
        if self.contentOffset.y < -(self.frame.height) {
            self.removeFromSuperview()
            self.whiteBackgroundLayer.removeFromSuperview()
        }
    }
    
    func setWhiteBackgroundLayout() {
        DispatchQueue.main.async {
            if self.contentOffset.y < 0 {
                self.whiteBackgroundLayer.pinFrame.all().marginTop(abs(self.contentOffset.y))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comment = self.data[indexPath.row] as? RedditComment {
            DispatchQueue.main.async {
                if comment.isMoreComment {
                    self.redditCommentMorePressed(comment: comment, indexPath: indexPath)
                } else if comment.isContinueThread {
                    self.redditCommentContinueThreadPressed()
                } else {
                    self.redditCommentContentPressed(comment: comment, indexPath: indexPath)
                }
            }
        }
    }
    
    /// when user taps load more comments button
    func redditCommentMorePressed(comment: RedditComment, indexPath: IndexPath) {
        RedditService.shared.getMoreComments(comment: comment, link_id: self.redditViewItem.redditPost.name) { comments in
            
            // delete load more row if we don't get any comments back
            if comments.count < 1 {
                self.data.remove(at: indexPath.row)
                self.beginUpdates()
                self.deleteRows(at: [indexPath], with: .automatic)
                self.endUpdates()
                return
            }
            
            var comments = comments
            
            self.data[indexPath.row] = comments.remove(at: 0)
            self.beginUpdates()
            self.reloadRows(at: [indexPath], with: .automatic)
            self.endUpdates()

            // check if we still have comments left to insert
            if comments.count > 0 {
                self.data.insert(contentsOf: comments, at: indexPath.row + 1)
                let indexPaths = (0...comments.count - 1).map { index in
                    return IndexPath(row: indexPath.row + 1 + index, section: 0)
                }
                self.beginUpdates()
                self.insertRows(at: indexPaths, with: .automatic)
                self.endUpdates()
            }
        }
    }
    
    func redditCommentContinueThreadPressed() {
        print("TODO: continue thread")
    }
    
    /// when user taps on normal content comment
    func redditCommentContentPressed(comment: RedditComment, indexPath: IndexPath) {
        comment.isCollapsed = !comment.isCollapsed
        
        var indexPaths = [indexPath]

        for i in indexPath.row...(self.data.count - 1) {
            if i == indexPath.row {
                continue
            }
            
            if let c = self.data[i] as? RedditComment {
                if c.depth > comment.depth {
                    c.isHidden = comment.isCollapsed
                    indexPaths.append(IndexPath(item: i, section: 0))
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        self.reloadRows(at: indexPaths, with: .fade)
    }
}
