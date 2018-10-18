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
        label.textColor = Config.colors.primaryFont
        return label
    }()

    lazy private var moreButton: UIButton = {
        let button = UIButton()
        self.contentView.addSubview(button)
        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        button.setIcon(icon: .fontAwesomeSolid(.ellipsisH), iconSize: 30, color: Config.colors.primaryLight, forState: .normal)
        return button
    }()

    func setRedditPost(post: RedditPost) {
        self.redditPost = post
        self.label.text = post.title
        self.label.numberOfLines = post.expandTitle ? 0 : 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-(self.moreButton.frame.width + 20))
            make.centerY.equalTo(self)
        }
        self.moreButton.snp.makeConstraints{ make in
            make.right.equalTo(self).offset(-15)
            make.centerY.equalTo(self)
        }
    }
    
    @objc func moreButtonAction() {
        Subjects.shared.moreButtonAction.onNext(self.redditPost!)
    }
}
