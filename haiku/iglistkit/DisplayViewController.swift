//
//  DisplayViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import IGListKit
import UIKit

class DisplayViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var data: [ListDiffable] = []
    let refreshControl = UIRefreshControl()

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 10)
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        if #available(iOS 10, *) {
            UICollectionView.appearance().isPrefetchingEnabled = false
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        self.adapter.collectionView = self.collectionView
        self.adapter.scrollViewDelegate = self
        self.adapter.dataSource = self
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(fetchInitial(_:)), for: .valueChanged)
        self.fetchInitial()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DisplaySectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing {
            if let redditPost = self.data[self.data.count - 1] as? RedditPost {
                self.refreshControl.beginRefreshing()
                self.fetchHaikus(redditPost.name)
            }
        }
    }

    @objc func fetchInitial(_ sender: Any? = nil) {
        if !self.refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {
        RedditService.shared.getHaikus(after: after){ redditPosts in
            self.data = after == nil ? redditPosts : self.data + redditPosts
            self.adapter.performUpdates(animated: true, completion: { _ in
                self.refreshControl.endRefreshing()
            })
        }
    }
}
