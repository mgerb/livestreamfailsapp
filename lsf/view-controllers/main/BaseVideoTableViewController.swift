//
//  BaseVideoTableViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 5/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import DifferenceKit

class BaseVideoTableViewController: UIViewController, UITableViewDataSource {
    
    let refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    
    var data = [RedditViewItem]()
    var workingRange = Set<Int>()
    var estimatedHeightCache = [String: CGFloat]()
    var commentsTableView: CommentsTableView?
    var readyToLoadMore = true

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
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        self.tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "VideoTableViewCell")
        self.tableView.register(SortBarTableViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: "SortBarTableViewHeaderCell")
        
        self.setupSubjectSubscriptions()
        self.fetchHaikus()
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
    }
    
    func setupSubjectSubscriptions() {
        // show comments list
        Subjects.shared.showCommentsAction.subscribe(onNext: { redditViewItem in
            if self.isViewLoaded && self.view?.window != nil {
                self.commentsTableView?.dismiss()
                if let frame = MyNavigation.shared.rootViewController()?.view.frame {
                    let totalNavItemHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + (self.tabBarController?.tabBar.frame.height ?? 0)
                    self.commentsTableView = CommentsTableView(frame: frame, redditViewItem: redditViewItem, totalNavItemHeight: totalNavItemHeight)
                    self.view.addSubview(self.commentsTableView!)
                }
            }
        }).disposed(by: self.disposeBag)
        
        Subjects.shared.moreButtonAction.subscribe(onNext: { redditViewItem in
            let alertController = RedditAlertController(redditViewItem: redditViewItem)
            alertController.delegate = self
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
}

// table/scroll view delegates
extension BaseVideoTableViewController: UITableViewDelegate, UIScrollViewDelegate {
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SortBarTableViewHeaderCell.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.data.indices.contains(indexPath.row) {
            let item = self.data[indexPath.row]
            self.estimatedHeightCache[item.redditLink.id] = cell.frame.height
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.data[indexPath.row]
        if item.failedToLoadVideo, let urlString = item.redditLink.url, let url = URL(string: urlString) {
            MyNavigation.shared.presentWebView(url: url)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

// my custom delegates
extension BaseVideoTableViewController: RedditViewItemDelegate, RedditAlertControllerDelegate {

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
    
    func didHideItem(redditViewItem: RedditViewItem) {
        let target: [RedditViewItem] = self.data.compactMap { $0.redditLink.id == redditViewItem.redditLink.id ? nil : $0 }

        if (try? GlobalPlayer.shared.activeRedditViewItem.value())??.redditLink.id == redditViewItem.redditLink.id {
            GlobalPlayer.shared.pause()
        }
        
        let changeset = StagedChangeset(source: self.data, target: target)
        self.tableView.reload(using: changeset, with: .fade) { data in
            self.data = data
        }
    }
}
