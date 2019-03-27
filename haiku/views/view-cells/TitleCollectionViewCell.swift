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
        
        let label = Labels.new(font: .regular, color: .primary)
        label.numberOfLines = 0
        return label
    }()

    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        _ = self.redditViewItem?.markedAsWatched.takeUntil(self.rxUnsubscribe).subscribe(onNext: { watched in
            self.label.textColor = watched && self.redditViewItem?.context == .home ? Config.colors.secondaryFont : Config.colors.primaryFont
        })
        
        DispatchQueue.main.async {
            self.label.text = item.redditPost.title.replaceEncoding()
        }
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
