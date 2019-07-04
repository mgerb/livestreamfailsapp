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
import MGSwipeTableCell
import DifferenceKit

class CommentsTableView: TapThroughTableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CommentsAlertDelegate {
    var didLoad = false
    var didFinishInitialAnimation = false
    var data: [AnyDifferentiable] = [AnyDifferentiable("loading")]
    private let footerHeight: CGFloat = 800
    let redditViewItem: RedditViewItem
    let totalNavItemHeight: CGFloat
    var estimatedHeightCache = [String: CGFloat]()
    
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

    private func transformComments(_ comments: [RedditListingType]) -> [AnyDifferentiable] {
        return comments.compactMap {
            switch $0 {
            case .redditComment(let c):
                return AnyDifferentiable(c)
            case .redditMore(let m):
                return AnyDifferentiable(m)
            default:
                return nil
            }
        }
    }
    
    func fetchComments (animate: Bool = false) {
        RedditService.shared.getComments(permalink: self.redditViewItem.redditLink.permalink) { comments in
            if let comments = comments {
                let comments = comments.count > 0 ? self.transformComments(comments) : [AnyDifferentiable("no comments")]
                if animate {
                    let changeset = StagedChangeset(source: self.data, target: comments)
                    self.reload(using: changeset, with: .fade) { data in
                        self.didLoad = true
                        self.data = data
                    }
                } else {
                    self.data = comments
                    self.didLoad = true
                    self.reloadData()
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

    // height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.data[indexPath.row].base {
        case let s as String:
            if s == "loading" || s == "no comments" {
                return UITableViewAutomaticDimension
            }
            break
        case let comment as RedditComment:
            if comment.isHidden {
                return 0
            } else if comment.isCollapsed || comment.isDeleted {
                return UITableViewAutomaticDimension
            }
        case let more as RedditMore:
            return more.isHidden || more.isContinueThread ? 0 : UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comment = self.data[indexPath.row].base as? RedditComment {
            return comment.isHidden ? 0 : (self.estimatedHeightCache[comment.id] ?? 25)
        }
        // TODO: remove hard coded height - 25 seems to work ok for now
        return 25
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.data.indices.contains(indexPath.row) {
            if let comment = self.data[indexPath.row].base as? RedditComment {
                self.estimatedHeightCache[comment.id] = cell.frame.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let comment = self.data[indexPath.row].base as? RedditComment {
            // return empty cell if hidden - improves performance tremendously
            if comment.isHidden {
                return self.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            } else {
                let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellContent", for: indexPath) as! CommentsViewCellContent
                cell.setRedditComment(c: comment)
                cell.delegate = self
                return cell
            }
        } else if let more = self.data[indexPath.row].base as? RedditMore {
            let cell = self.dequeueReusableCell(withIdentifier: "CommentsViewCellMore", for: indexPath) as! CommentsViewCellMore
            cell.setRedditComment(c: more)
            return cell
        } else if let c = self.data[indexPath.row].base as? String {
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
        if self.contentOffset.y < 0 {
            // TODO: revisit this - seems to work okay now though
            self.whiteBackgroundLayer.snp.remakeConstraints { make in
                make.left.right.bottom.equalToSuperview().priority(999)
                make.top.equalToSuperview().offset(abs(self.contentOffset.y)).priority(999)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            if let comment = self.data[indexPath.row].base as? RedditComment {
                self.redditCommentContentPressed(comment: comment, indexPath: indexPath)
            } else if let more = self.data[indexPath.row].base as? RedditMore {
                if more.isContinueThread {
                    self.redditCommentContinueThreadPressed()
                } else {
                    self.redditCommentMorePressed(more: more, indexPath: indexPath)
                }
            }
        }
    }
    
    /// when user taps load more comments button
    func redditCommentMorePressed(more: RedditMore, indexPath: IndexPath) {
        RedditService.shared.getMoreComments(more: more, link_id: self.redditViewItem.redditLink.name) { comments in
            
            var target = self.data
            
            let comments = self.transformComments(comments)
            target.remove(at: indexPath.row)
            target.insert(contentsOf: comments, at: indexPath.row)
            
            let changeset = StagedChangeset(source: self.data, target: target)
            
            self.reload(using: changeset, with: .fade) { data in
                self.data = data
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
            
            var tempComment: RedditCommentProtocol?

            if let c = self.data[i].base as? RedditComment {
                tempComment = c
            } else if let more = self.data[i].base as? RedditMore {
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
        }
        
        self.reloadRows(at: indexPaths, with: .fade)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.data.count - 1, section: 0)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func commentAdded(comment: RedditComment, parent: RedditComment?) {
        let index = self.data.firstIndex {
            if let c = $0.base as? RedditComment {
                return c.id == parent?.id
            }
            return false
        }

        var target = self.data
        if let index = index {
            target.insert(AnyDifferentiable(comment), at: index + 1)
        } else {
            // check if showing the "no comments message"
            if self.data.contains(where: { $0.base as? String != nil }) {
                target = [AnyDifferentiable(comment)]
            } else {
                target.append(AnyDifferentiable(comment))
            }
        }
        let changeset = StagedChangeset(source: self.data, target: target)
        self.reload(using: changeset, with: .fade) { data in
            self.data = data
            if index == nil {
                self.scrollToBottom()
            }
        }
    }
    
    func commentDeleted(comment: RedditComment) {
        let index = self.data.firstIndex {
            if let c = $0.base as? RedditComment {
                return c.id == comment.id
            }
            return false
        }
        
        if let index = index {
            var target = self.data
            target.remove(at: index)
            let changeset = StagedChangeset(source: self.data, target: target)
            self.reload(using: changeset, with: .fade) { data in
                self.data = data
            }
        }
    }
    
    func addCommentAction(parent: RedditComment?) {
        if !RedditService.shared.isLoggedIn() {
            MyNavigation.shared.presetLoginAlert()
            return
        }
        let commentsReplyViewController = CommentsReplyViewController(parentName: parent?.name ?? self.redditViewItem.redditLink.name, parentComment: parent)
        commentsReplyViewController.success = { newComment in
            self.commentAdded(comment: newComment, parent: parent)
        }
        let navController = UINavigationController(rootViewController: commentsReplyViewController)
        navController.modalTransitionStyle = .coverVertical
        MyNavigation.shared.rootViewController()?.present(navController, animated: true, completion: nil)
    }
    
    func deleteCommentAction(comment: RedditComment) {
        RedditService.shared.delete(name: comment.name, completion: { success in
            if success {
                self.commentDeleted(comment: comment)
            }
        })
    }
}

extension CommentsTableView: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {

        swipeSettings.keepButtonsSwiped = false
        swipeSettings.transition = MGSwipeTransition.clipCenter
        expansionSettings.fillOnTrigger = false
        expansionSettings.buttonIndex = 0
        expansionSettings.threshold = 1.0
        expansionSettings.expansionColor = Config.colors.blue
        expansionSettings.expansionLayout = .center
        expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunction.cubicInOut

        if direction == MGSwipeDirection.rightToLeft {
            let button = MGSwipeButton(title: "", icon: Icons.getImage(icon: .dots, size: 30, color: Config.colors.white), backgroundColor: Config.colors.bg4, padding: 35, callback: { cell in
                return true
            })
            return [button]
        }

        return nil
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if let indexPath = self.indexPath(for: cell) {
            if let comment = self.data[indexPath.row].base as? RedditComment {
                let alert = CommentsAlertController(comment: comment)
                alert.delegate = self
                MyNavigation.shared.rootViewController()?.present(alert, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        if state == .expandingLeftToRight || state == .expandingRightToLeft {
            Util.hapticFeedback()
        }
    }
}
