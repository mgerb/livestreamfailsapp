//
//  TitleCollectionViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift

class TitleCollectionViewCell: UICollectionViewCell {
    
    static let padding = CGFloat(10)
    var redditViewItem: RedditViewItem?
    let rxUnsubscribe = PublishSubject<Void>()
    
    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = Config.defaultFont
        label.textColor = Config.colors.primaryFont
        return label
    }()

    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.label.text = item.redditPost.title.replaceEncoding()
        self.label.numberOfLines = 0
        _ = self.redditViewItem?.markedAsWatched.takeUntil(self.rxUnsubscribe).subscribe(onNext: { watched in
            self.label.textColor = watched && self.redditViewItem?.context == .home ? Config.colors.primaryLight : Config.colors.primaryFont
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.label)
        self.label.pin.all(TitleCollectionViewCell.padding)
    }
    
    override func prepareForReuse() {
        self.rxUnsubscribe.onNext(())
    }
}
