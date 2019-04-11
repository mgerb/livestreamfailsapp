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
    
    static func calculateHeight(redditViewItem: RedditViewItem) -> CGFloat {
        let padding = (CommentsHeaderCell.cellPadding * 2) + 25
        let width = UIScreen.main.bounds.width - (CommentsHeaderCell.cellPadding * 2) - CommentsHeaderCell.calculateTitleScoreOffset(redditViewItem: redditViewItem)
        return padding + redditViewItem.getTitleLabelText().heightWithConstrainedWidth(width: width, font: Config.regularBoldFont)
    }
    
    static func calculateTitleScoreOffset(redditViewItem: RedditViewItem) -> CGFloat {
        return 5 + redditViewItem.redditPost.score.commaRepresentation.widthWithConstrainedHeight(height: 10, font: Config.regularFont)
    }
    
    static let cellPadding = CGFloat(10)

    var redditViewItem: RedditViewItem?
    
    let bgView = UIView()

    lazy var titleLabel: UILabel = {
        let label = Labels.new(font: .regularBold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nsfwLabel: UILabel = {
        let label = Labels.nsfwLabel()
        label.isHidden = true
        return label
    }()

    lazy var authorLabel = Labels.new(font: .small)
    lazy var timestampLabel = Labels.new(font: .small)
    lazy var scoreLabel = Labels.new(color: .secondary)
    lazy var commentLabel = Labels.new(color: .secondary)
    lazy var commentBubble = Icons.getLabel(icon: .comment, size: Config.regularFont.pointSize, color: Config.colors.secondaryFont)

    lazy var topBorder = getBorder()
    lazy var bottomBorder = getBorder()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = Config.colors.bg1
        
        self.addSubview(self.bgView)
        self.addSubview(self.topBorder)
        self.addSubview(self.bottomBorder)

        self.bgView.addSubview(self.titleLabel)
        self.bgView.addSubview(self.nsfwLabel)
        self.bgView.addSubview(self.authorLabel)
        self.bgView.addSubview(self.scoreLabel)
        self.bgView.addSubview(self.timestampLabel)
        self.bgView.addSubview(self.commentLabel)
        self.bgView.addSubview(self.commentBubble)

        self.bgView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(CommentsHeaderCell.cellPadding)
            make.right.equalTo(self).offset(-CommentsHeaderCell.cellPadding)
            make.top.equalTo(self).offset(CommentsHeaderCell.cellPadding)
            make.bottom.equalTo(self).offset(-CommentsHeaderCell.cellPadding)
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.right.top.equalTo(self.bgView)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.bgView)
        }
        
        self.nsfwLabel.snp.makeConstraints { make in
            make.left.top.equalTo(self.bgView)
            make.height.equalTo(self.nsfwLabel.intrinsicContentSize.height + 3)
            make.width.equalTo(self.nsfwLabel.intrinsicContentSize.width + 5)
        }

        self.authorLabel.snp.makeConstraints { make in
            make.left.bottom.equalTo(self.bgView)
        }
        
        self.timestampLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.bgView)
            make.left.equalTo(self.authorLabel.snp.right)
        }
        
        self.topBorder.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(Config.borderWidth)
        }
        
        self.bottomBorder.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(Config.borderWidth)
        }
        
        self.commentLabel.snp.makeConstraints { make in
            make.bottom.right.equalTo(self.bgView)
        }
        
        self.commentBubble.snp.makeConstraints { make in
            make.bottom.equalTo(self.bgView)
            make.right.equalTo(self.commentLabel.snp.left).offset(-5)
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        self.titleLabel.snp.updateConstraints { make in
            if let item = self.redditViewItem {
                make.right.equalTo(self.bgView).offset(-CommentsHeaderCell.calculateTitleScoreOffset(redditViewItem: item))
            }
        }
        
        super.updateConstraints()
    }

    func setRedditViewItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        self.titleLabel.text = redditViewItem.getTitleLabelText()
        self.authorLabel.text = redditViewItem.redditPost.author
        self.timestampLabel.text = " · " + redditViewItem.humanTimeStamp
        self.nsfwLabel.isHidden = !redditViewItem.redditPost.over_18
        self.scoreLabel.text = redditViewItem.redditPost.score.commaRepresentation
        self.commentLabel.text = redditViewItem.redditPost.num_comments.commaRepresentation
    }
    
    func getBorder() -> UIView {
        let view = UIView()
        view.backgroundColor = Config.colors.bg2
        return view
    }
}
