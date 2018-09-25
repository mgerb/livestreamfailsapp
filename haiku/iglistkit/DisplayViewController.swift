//
//  DisplayViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import IGListKit
import UIKit

class DisplayViewController: UIViewController, ListAdapterDataSource {
    var data: [ListDiffable] = []
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 10)
    }()
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        self.fetchHaikus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DisplaySectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    
    func fetchHaikus(_ after: String? = nil) {
        RedditService.shared.getHaikus(after: after){ redditPosts in
            self.data = redditPosts
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
}
