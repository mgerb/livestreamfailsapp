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
        self.navigationItem.title = "Favorites"
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { _ in
            self.fetchHaikus()
        }).disposed(by: self.disposeBag)
    }
    
    override func fetchHaikus(_ after: String? = nil) {
        super.fetchHaikus()
        
        // delay or else images don't show up right away
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            let redditLinks = StorageService.shared.getRedditLinkFavorites()
            // create section view items from reddit links
            self.data = redditLinks.map { RedditViewItem($0, context: .favorites) }
            self.adapter.performUpdates(animated: true, completion: nil)
        })
    }
}
