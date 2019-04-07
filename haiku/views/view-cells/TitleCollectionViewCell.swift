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
import SnapKit

class TitleCollectionViewCell: UICollectionViewCell {
    
    static let padding = CGFloat(10)
    var redditViewItem: RedditViewItem?
    let rxUnsubscribe = PublishSubject<Void>()
    
    lazy private var label: UILabel = {
        let label = Labels.new(font: .regular, color: .primary)
        label.numberOfLines = 0
        return label
    }()

    lazy private var nsfwLabel: UILabel = {
        let label = Labels.newAccent(color: .red)
        label.text = "NSFW"
        return label
    }()

    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        _ = self.redditViewItem?.markedAsWatched.takeUntil(self.rxUnsubscribe).subscribe(onNext: { watched in
            self.label.textColor = watched && self.redditViewItem?.context == .home ? Config.colors.secondaryFont : Config.colors.primaryFont
        })
        
        DispatchQueue.main.async {
            self.label.text = item.getTitleLabelText()
            self.nsfwLabel.isHidden = !item.redditPost.over_18
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.label)
        self.addSubview(self.nsfwLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.pin.all(TitleCollectionViewCell.padding)
        self.nsfwLabel.pin.top().left()
            .height(self.nsfwLabel.intrinsicContentSize.height + 3)
            .width(self.nsfwLabel.intrinsicContentSize.width + 5)
            .marginLeft(TitleCollectionViewCell.padding).marginTop(TitleCollectionViewCell.padding)
    }
    
    override func prepareForReuse() {
        self.rxUnsubscribe.onNext(())
    }
}
