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

class VideoTableViewController: UIViewController, UITableViewDataSource {

    var data = [RedditViewItem]()
    var workingRange = Set<Int>()
    var estimatedHeightCache = [String: CGFloat]()
    let disposeBag = DisposeBag()
    var commentsTableView: CommentsTableView?
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
        view.separatorStyle = .none
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
        
        self.tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "VideoTableViewCell")
        self.tableView.register(SortBarTableViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: "SortBarTableViewHeaderCell")

        self.setupSubjectSubscriptions()
        self.fetchHaikus()
    }
    
    override func viewWillLayoutSubviews() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.addSubview(self.revealingSplashView)
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
                    self.tableView.setContentOffset(CGPoint(x: 0, y: SortBarCollectionViewCell.height), animated: true)
                    self.setReddyToLoadMore()
                } else {
                    // if we don't return any reddit items wait at least 10 seconds before trying again
                    if redditViewItems.count == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: self.loadMoreTimeoutWorkItem!)
                        return
                    }
                    
                    self.tableView.reload(using: changeset, with: .fade) { data in
                        self.data = data

                        self.loadMoreTimeoutWorkItem = DispatchWorkItem {
                            self.setReddyToLoadMore()
                        }

                            self.setReddyToLoadMore()

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
    
    func setupSubjectSubscriptions() {
        // show comments list
        Subjects.shared.showCommentsAction.subscribe(onNext: { redditViewItem in
            if self.isViewLoaded && self.view?.window != nil {
                self.commentsTableView?.dismiss()
                if let frame = MyNavigation.shared.rootViewController?.view.frame {
                    let totalNavItemHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + (self.tabBarController?.tabBar.frame.height ?? 0)
                    self.commentsTableView = CommentsTableView(frame: frame, redditViewItem: redditViewItem, totalNavItemHeight: totalNavItemHeight)
                    self.view.addSubview(self.commentsTableView!)
                }
            }
        }).disposed(by: self.disposeBag)
    }
}

// table/scroll view delegates
extension VideoTableViewController: UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.data[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
        cell.setRedditItem(redditViewItem: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.estimatedHeightCache[self.data[indexPath.row].redditLink.id] ?? VideoTableViewCell.getEstimatedHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SortBarTableViewHeaderCell") as! SortBarTableViewHeaderCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SortBarTableViewHeaderCell.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = self.data[indexPath.row]
        self.estimatedHeightCache[item.redditLink.id] = cell.frame.height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = self.data[indexPath.row]
        item.delegate.add(delegate: self)
        
        let range = Set((indexPath.row-5...indexPath.row+5).compactMap {
            self.data.indices.contains($0) ? $0 : nil
        })
        
        let didEnterRange = range.subtracting(self.workingRange)
        
        // preload thumbnails when entering working range
        DispatchQueue.main.async {
            didEnterRange.forEach {
                if self.data.indices.contains($0) {
                    _ = self.data[$0].getThumbnailImage.subscribe()
                }
            }
        }
        
        self.workingRange = range
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing && self.readyToLoadMore && self.data.count > 0 {
            let redditViewItem = self.data[self.data.count - 1]
            self.readyToLoadMore = false
            self.fetchHaikus(redditViewItem.redditLink.name)
        }
    }
}

// my custom delegates
extension VideoTableViewController: RedditViewItemDelegate, SortBarTableViewHeaderCellDelegate {
    
    func failedToLoadVideo(redditViewItem: RedditViewItem) {
        let index = self.data.firstIndex { $0.redditLink.id == redditViewItem.redditLink.id }
        if let index = index {
            self.estimatedHeightCache.removeValue(forKey: redditViewItem.redditLink.id)
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    func didMarkAsWatched(redditViewItem: RedditViewItem) {}
    
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
