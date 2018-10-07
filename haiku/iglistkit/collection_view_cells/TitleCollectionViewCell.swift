//
//  TitleCollectionViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class TitleCollectionViewCell: UICollectionViewCell {
    
    var redditPost: RedditPost?
    
    lazy private var label: UILabel = {
        let label = UILabel()
        self.contentView.addSubview(label)
        label.font = Config.defaultFont
        label.numberOfLines = 0
        return label
    }()

    func setRedditPost(post: RedditPost) {
        self.label.text = post.title
        self.label.numberOfLines = post.expandTitle ? 0 : 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-5)
            make.centerY.equalTo(self)
        }
    }
}
