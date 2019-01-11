//
//  CommentsCollectionViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import DynamicJSON

class CommentsCollectionView: TapThroughCollectionView, ListAdapterDataSource, UIScrollViewDelegate {
    
    var adapter: ListAdapter?
    var data: [ListDiffable] = [RedditComment(json: JSON(["id":"test"]))]

    static func getInstance(_ controller: UIViewController, _ redditViewItem: RedditViewItem) -> CommentsCollectionView {
        let view = CommentsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.setup(controller, redditViewItem)
        return view
    }

    func setup(_ controller: UIViewController, _ redditViewItem: RedditViewItem) {
        self.backgroundColor = .clear
        self.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.height, left: 0, bottom: 0, right: 0)
        self.showsVerticalScrollIndicator = false
        self.adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: controller, workingRangeSize: 10)
        self.adapter?.collectionView = self
        self.adapter?.dataSource = self
        self.adapter?.scrollViewDelegate = self
        
        // TODO:
        RedditService.shared.getFlattenedComments(permalink: redditViewItem.redditPost.permalink) {comments in
            self.data = comments
            self.adapter?.performUpdates(animated: true, completion: { _ in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        self.contentOffset = CGPoint(x: 0, y: -(UIScreen.main.bounds.height / 2))
                    }, completion: nil)
                }
            })
        }
    }

    // when controller add this as subview
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.contentOffset = CGPoint(x: 0, y: -UIScreen.main.bounds.height)
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        // this can be anything!
        return self.data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        print(object)
        return CommentsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.contentOffset.y < -(UIScreen.main.bounds.height) {
            self.removeFromSuperview()
        }
    }
}
