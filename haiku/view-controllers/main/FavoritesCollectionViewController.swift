//
//  FavoritesViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/21/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation

class FavoritesCollectionViewController: YaikuCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { _ in
            self.fetchHaikus()
        }).disposed(by: self.disposeBag)
    }
    
    override func fetchHaikus(_ after: String? = nil) {
        let redditPosts = StorageService.shared.getRedditPostFavorites()
        // create section view items from reddit posts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.data = redditPosts.map { RedditViewItem($0, context: .favorites) }
            self.adapter.performUpdates(animated: true, completion: { _ in
                self.refreshControl.endRefreshing()
            })
        }
    }
}
