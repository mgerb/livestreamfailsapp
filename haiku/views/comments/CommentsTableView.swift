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
    private let footerHeight: CGFloat = 800
    let redditViewItem: RedditViewItem
    let totalNavItemHeight: CGFloat
    
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
    
    // offsetTop should be total height of navbars/tabbars
    init(frame: CGRect, redditViewItem: RedditViewItem, totalNavItemHeight: CGFloat) {
        self.redditViewItem = redditViewItem
        self.totalNavItemHeight = totalNavItemHeight
        super.init(frame: frame, style: .grouped)

        self.separatorStyle = .none
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension

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
                    self.contentOffset.y = -(self.frame.height / 2) + self.totalNavItemHeight
                }, completion: {_ in
                    DispatchQueue.main.async {
                        self.didFinishInitialAnimation = true
                        self.setWhiteBackgroundLayout()
                        self.contentInset.bottom = -(self.footerHeight - 400)
                    }
                    self.fetchComments()
                })
            }
        }
    }

    func fetchComments () {
        RedditService.shared.getComments(permalink: self.redditViewItem.redditLink.permalink) { comments in
            if let comments = comments {
                self.data = comments.count > 0 ? comments : ["no comments"]
                self.didLoad = true
                self.reloadData()
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

    // height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.data[indexPath.row] {
        case let s as String:
            if s == "loading" || s == "no comments" {
                return 200
            }
            break
        case let listing as RedditListingType:
            if case .redditComment(let comment) = listing {
                if comment.isHidden {
                    return 0
                } else if comment.isCollapsed || comment.isDeleted {
                    return 40
                } else {
                    return CommentsViewCellContent.getHeight(redditComment: comment)
                }
            } else if case .redditMore(let more) = listing {
                return more.isHidden ? 0 : 30
            }
        default:
            return 50
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listing = self.data[indexPath.row] as? RedditListingType {
            
            switch listing {
            case .redditComment(let comment):
                // return empty cell if hidden - improves performance tremendously
                if comment.isHidden {
                    return self.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
                } else {
                    let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellContent", for: indexPath) as! CommentsViewCellContent
                    cell.setRedditComment(c: comment)
                    return cell
                }
            case .redditMore(let more):
                let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellMore", for: indexPath) as! CommentsViewCellMore
                cell.setRedditComment(c: more)
                return cell
            default:
                break
            }
        }  else if let c = self.data[indexPath.row] as? String {
            let cell = self.dequeueReusableCell(withIdentifier: "CommentsLoadingCell", for: indexPath) as! CommentsLoadingCell
            c == "loading" ? cell.setLoading() : cell.setNoComments()
            return cell
        }
        
        return self.dequeueReusableCell(withIdentifier: "CommentsLoadingCell", for: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCell") as! CommentsHeaderCell
        cell.setRedditViewItem(redditViewItem: self.redditViewItem)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = self.dequeueReusableHeaderFooterView(withIdentifier: "FooterCell")
        cell?.contentView.backgroundColor = Config.colors.bg1
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
        if let listing = self.data[indexPath.row] as? RedditListingType {
            DispatchQueue.main.async {
                if case .redditComment(let comment) = listing {
                    self.redditCommentContentPressed(comment: comment, indexPath: indexPath)
                } else if case .redditMore(let more) = listing {
                    if more.isContinueThread {
                        self.redditCommentContinueThreadPressed()
                    } else {
                        self.redditCommentMorePressed(more: more, indexPath: indexPath)
                    }
                }
            }
        }
    }
    
    /// when user taps load more comments button
    func redditCommentMorePressed(more: RedditMore, indexPath: IndexPath) {
        RedditService.shared.getMoreComments(more: more, link_id: self.redditViewItem.redditLink.name) { comments in
            
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
            
            if let listing = self.data[i] as? RedditListingType {
                var tempComment: RedditCommentProtocol?
                
                if case .redditComment(let c) = listing {
                    tempComment = c
                } else if case .redditMore(let more) = listing {
                    tempComment = more
                }
                
                if let c = tempComment {
                    if c.depth > comment.depth {
                        c.isHidden = comment.isCollapsed
                        indexPaths.append(IndexPath(item: i, section: 0))
                    } else {
                        break
                    }
                }
            } else {
                break
            }
        }
        
        self.reloadRows(at: indexPaths, with: .fade)
    }
}
