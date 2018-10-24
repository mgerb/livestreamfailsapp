//
//  FavoritesViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/21/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation

class FavoritesViewController: YaikuCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Subjects.shared.favoriteButtonAction.subscribe(onNext: { _ in
            self.fetchHaikus()
        }).disposed(by: self.disposeBag)
    }
    
    override func fetchHaikus(_ after: String? = nil) {
        self.data = StorageService.shared.getRedditPostFavorites()
        self.adapter.performUpdates(animated: true, completion: { _ in
            self.refreshControl.endRefreshing()
        })
    }
}
