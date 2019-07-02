//
//  global-actions.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/17/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import RxSwift

/// store global events here
class Subjects {
    static let shared = Subjects()
    let moreButtonAction = PublishSubject<RedditViewItem>()
    let favoriteButtonAction = PublishSubject<RedditViewItem>()
    let fullScreenPlayerAction = PublishSubject<RedditViewItem>()
    let showCommentsAction = PublishSubject<RedditViewItem>()
}
