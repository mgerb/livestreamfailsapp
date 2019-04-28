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

class VideoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var data = [RedditViewItem]()
    private var readyToLoadMore = true
    private var loadMoreTimeoutWorkItem: DispatchWorkItem?
    private var redditLinkSortBy = RedditLinkSortBy.hot
    private var redditLinkSortByTop = RedditLinkSortByTop.week
    private let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "app_icon.png")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:1, green:1, blue:1, alpha:1.0))
    private let refreshControl = UIRefreshControl()
    private var didShowAnimation = false

    lazy var tableView: UITableView = {
        let view = UITableView(frame: self.view.frame, style: .grouped)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(fetchInitial(_:)), for: .valueChanged)
        
        self.navigationItem.title = "Live Stream Fails"
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VideoTableViewCell")
        // TODO:
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "VideoTableViewHeaderCell")

        self.fetchHaikus()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = self.data[indexPath.row] as? RedditViewItem {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath)
            cell.textLabel?.text = item.redditLink.title
            return cell
        }
        
        return self.tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "VideoTableViewHeaderCell")
        cell?.textLabel?.text = "header"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing && self.readyToLoadMore && self.data.count > 0 {
            if let redditViewItem = self.data[self.data.count - 1] as? RedditViewItem {
                self.readyToLoadMore = false
                self.fetchHaikus(redditViewItem.redditLink.name)
            }
        }
    }
    
    @objc func fetchInitial(_ sender: Any? = nil) {
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {
        if after == nil {
            if !self.refreshControl.isRefreshing {
                self.refreshControl.beginRefreshing()
            }
        }
        
        // cancel load more timeout if we reload the data completely
        if after == nil {
            self.loadMoreTimeoutWorkItem?.cancel()
            GlobalPlayer.shared.pause()
        }
        
        RedditService.shared.getHaikus(after: after, sortBy: self.redditLinkSortBy, sortByTop: self.redditLinkSortByTop){ redditLinks in
            let redditViewItems: [RedditViewItem] = redditLinks.compactMap {
                let item = RedditViewItem($0, context: .home)
                return item
            }
            
            DispatchQueue.main.async {
                
                // TODO:
//                let sortBar = ["sort bar"] as [ListDiffable]
                
                var target: [RedditViewItem] = []
                
                if after == nil {
//                    self.data = sortBar + redditViewItems
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
                    // TODO
//                    self.collectionView.setContentOffset(CGPoint(x: 0, y: SortBarCollectionViewCell.height), animated: true)
                    self.readyToLoadMore = true
                } else {
                    self.tableView.reload(using: changeset, with: .fade) { data in
                        self.data = data
                        self.loadMoreTimeoutWorkItem = DispatchWorkItem {
                            self.readyToLoadMore = true
                        }
                        // if we don't return any reddit items wait at least 10 seconds before trying again
                        if redditViewItems.count == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: self.loadMoreTimeoutWorkItem!)
                        } else {
                            self.readyToLoadMore = true
                        }
                    }
                }
            }
        }
    }
}
