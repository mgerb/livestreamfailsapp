//
//  FavoriteTableViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 5/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

class FavoritesTableViewController: BaseVideoTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchHaikus()
        self.navigationItem.title = "Favorites"
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { _ in
            self.fetchHaikus()
        }).disposed(by: self.disposeBag)
    }
    
    override func fetchHaikus(_ after: String? = nil) {
        super.fetchHaikus(after)
        
        // delay or else images don't show up right away
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            let redditLinks = StorageService.shared.getRedditLinkFavorites()
            let changeset = StagedChangeset(source: self.data, target: redditLinks.map { RedditViewItem($0, context: .favorites) })
            self.refreshControl.endRefreshing()
            self.tableView.reload(using: changeset, with: .fade) { data in
                self.data = data
            }
        })
    }
}
