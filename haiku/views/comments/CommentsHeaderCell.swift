//
//  CommentsHeaderCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/12/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CommentsHeaderCell: UITableViewHeaderFooterView {

    var redditViewItem: RedditViewItem?

    lazy var titleLabel: UILabel = {
        let label = Labels.new(font: .regularBold)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var nsfwLabel: UILabel = {
        let label = Labels.nsfwLabel()
        label.isHidden = true
        return label
    }()

    lazy var authorLabel = Labels.new(font: .small)
    lazy var scoreLabel = Labels.new(color: .secondary)
    lazy var commentLabel = Labels.new(color: .secondary)
    lazy var commentBubble = Icons.getLabel(icon: .comment, size: Config.regularFont.pointSize, color: Config.colors.secondaryFont)

    lazy var topBorder = getBorder()
    lazy var bottomBorder = getBorder()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = Config.colors.bg1
        
        self.contentView.addSubview(self.topBorder)
        self.contentView.addSubview(self.bottomBorder)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.nsfwLabel)
        self.contentView.addSubview(self.authorLabel)
        self.contentView.addSubview(self.scoreLabel)
        self.contentView.addSubview(self.commentLabel)
        self.contentView.addSubview(self.commentBubble)

        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
            make.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
            // needs low prio to not cause auto layout warning
            make.bottom.equalTo(self.authorLabel.snp.top).offset(-15).priorityLow()
            make.right.lessThanOrEqualTo(self.scoreLabel.snp.left).offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.nsfwLabel.snp.makeConstraints { make in
            make.left.top.equalTo(self.titleLabel)
            make.height.equalTo(self.nsfwLabel.intrinsicContentSize.height + 3)
            make.width.equalTo(self.nsfwLabel.intrinsicContentSize.width + 5)
        }
        
        self.authorLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
            make.bottom.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.topBorder.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.contentView)
            make.height.equalTo(Config.borderWidth)
        }
        
        self.bottomBorder.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self.contentView)
            make.height.equalTo(Config.borderWidth)
        }
        
        self.commentLabel.snp.makeConstraints { make in
            make.bottom.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.commentBubble.snp.makeConstraints { make in
            make.centerY.equalTo(self.commentLabel)
            make.right.equalTo(self.commentLabel.snp.left).offset(-5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRedditViewItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        self.titleLabel.text = redditViewItem.getTitleLabelText()
        self.authorLabel.text = redditViewItem.redditLink.author + " · " + redditViewItem.humanTimeStamp
        self.nsfwLabel.isHidden = !redditViewItem.redditLink.over_18
        self.scoreLabel.text = redditViewItem.redditLink.score.commaRepresentation
        self.commentLabel.text = redditViewItem.redditLink.num_comments.commaRepresentation
    }
    
    func getBorder() -> UIView {
        let view = UIView()
        view.backgroundColor = Config.colors.bg2
        return view
    }
}
