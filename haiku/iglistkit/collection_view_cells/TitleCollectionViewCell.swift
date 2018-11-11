//
//  TitleCollectionViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit
import FlexLayout
import PinLayout

class TitleCollectionViewCell: UICollectionViewCell {
    
    static let padding = CGFloat(10)
    var redditViewItem: RedditViewItem?
    
    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = Config.defaultFont
        label.textColor = Config.colors.primaryFont
        return label
    }()

    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.label.text = item.redditPost.title
        self.label.numberOfLines = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.label)
        self.label.pin.all(TitleCollectionViewCell.padding)
    }
}
