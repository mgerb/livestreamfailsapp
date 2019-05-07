//
//  VideoTableViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/27/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
import RevealingSplashView
import RxSwift

class VideoTableViewController: BaseVideoTableViewController {

    private var redditLinkSortBy = RedditLinkSortBy.hot
    private var redditLinkSortByTop = RedditLinkSortByTop.week
    private let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "app_icon.png")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:1, green:1, blue:1, alpha:1.0))
    private var didShowAnimation = false
    lazy private var loadMoreTimeoutWorkItem = DispatchWorkItem {
        self.setReddyToLoadMore()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Live Stream Fails"
    }
    
    override func viewWillLayoutSubviews() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.addSubview(self.revealingSplashView)
        }
    }

    override func fetchHaikus(_ after: String? = nil) {
        super.fetchHaikus(after)

        // cancel load more timeout if we reload the data completely
        if after == nil {
            self.loadMoreTimeoutWorkItem.cancel()
            GlobalPlayer.shared.pause()
        }
        
        RedditService.shared.getHaikus(after: after, sortBy: self.redditLinkSortBy, sortByTop: self.redditLinkSortByTop){ redditLinks in
            let redditViewItems: [RedditViewItem] = redditLinks.compactMap { RedditViewItem($0, context: .home) }
            
            DispatchQueue.main.async {
                
                var target: [RedditViewItem] = []

                if after == nil {
                    target = redditViewItems
                } else {
                    target = self.data + redditViewItems
                }

                let changeset = StagedChangeset(source: self.data, target: target)
                
                self.refreshControl.endRefreshing()
                
                // start twitter like animation
                if !self.didShowAnimation {
                    self.revealingSplashView.startAnimation() {
                        self.didShowAnimation = true
                    }
                }
                
                if after == nil {
                    self.tableView.reload(using: changeset, with: .fade) { data in
                        self.data = data
                    }
                    self.tableView.setContentOffset(CGPoint(x: 0, y: SortBarTableViewHeaderCell.height), animated: true)
                    self.setReddyToLoadMore()
                } else {
                    // if we don't return any reddit items wait at least 10 seconds before trying again
                    if redditViewItems.count == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: self.loadMoreTimeoutWorkItem)
                    } else {
                        self.tableView.reload(using: changeset, with: .fade) { data in
                            self.data = data
                            self.setReddyToLoadMore()
                        }
                    }
                }
            }
        }
    }
    
    func setReddyToLoadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.readyToLoadMore = true
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SortBarTableViewHeaderCell") as! SortBarTableViewHeaderCell
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing && self.readyToLoadMore && self.data.count > 0 {
            let redditViewItem = self.data[self.data.count - 1]
            self.readyToLoadMore = false
            self.fetchHaikus(redditViewItem.redditLink.name)
        }
    }
}

extension VideoTableViewController: SortBarTableViewHeaderCellDelegate {
    func sortBarDidUpdate(sortBy: RedditLinkSortBy) {
        self.redditLinkSortBy = sortBy
        
        // show alert controller
        if self.redditLinkSortBy == .top {
            let controller = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
            
            RedditLinkSortByTop.allCases.forEach { val in
                let action = UIAlertAction(title: val.rawValue, style: .default, handler: { _ in
                    self.redditLinkSortByTop = val
                    self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
                    self.fetchHaikus()
                })
                controller.addAction(action)
            }
            
            controller.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
        } else {
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
            self.fetchHaikus()
        }
    }
    
    func activeRedditLinkSortBy() -> RedditLinkSortBy {
        return self.redditLinkSortBy
    }
}
