//
//  CommentsViewCellContent.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CommentsViewCellContent: CommentsViewCell, RedditCommentDelegate {

    lazy var authorLabel: UILabel = {
        let label = Labels.new(font: .regularBold)
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = Labels.new(color: .secondary)
        return label
    }()
    
    lazy var timeStampLabel: UILabel = {
        let label = Labels.new(color: .secondary)
        return label
    }()

    lazy var body: CommentsTextView = {
        let view = CommentsTextView()
        view.backgroundColor = Config.colors.bg1
        view.isScrollEnabled = false
        view.isEditable = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.authorLabel)
        self.contentView.addSubview(self.body)
        self.contentView.addSubview(self.timeStampLabel)
        self.contentView.addSubview(self.scoreLabel)

        self.authorLabel.snp.makeConstraints { make in
            make.top.left.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
        }
        
        self.body.snp.makeConstraints { make in
            make.left.equalTo(self.authorLabel)
            make.top.equalTo(self.authorLabel.snp.bottom).offset(5).priorityLow()
            make.bottom.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.timeStampLabel.snp.makeConstraints { make in
            make.left.equalTo(self.authorLabel.snp.right)
            make.top.equalTo(self.authorLabel)
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(self.authorLabel)
            make.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRedditComment(c: RedditComment) {
        super.setRedditComment(c: c)

        self.contentView.alpha = c.isCollapsed ? 0.3 : 1
        self.body.isHidden = c.isHidden || c.isCollapsed || c.isDeleted
        self.body.attributedText = c.htmlBody
        self.authorLabel.text = c.author
        self.timeStampLabel.text = " · " + c.humanTimeStamp
        self.scoreLabel.text = c.score.commaRepresentation
        
        c.delegate = self
        self.setupUpvoteDownvote(comment: c)
        
        self.authorLabel.snp.remakeConstraints { make in
            make.top.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
            make.left.equalTo(self.contentView).offset((c.depth * 10) + Config.BaseDimensions.cellPadding)
            if c.isCollapsed {
                make.bottom.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
            }
        }
    }
    
    func setupUpvoteDownvote(comment: RedditComment) {
        if comment.likes == true {
            self.scoreLabel.textColor = Config.colors.upvote
            self.scoreLabel.text = (comment.score + 1).commaRepresentation
        } else if comment.likes == false {
            self.scoreLabel.textColor = Config.colors.downvote
            self.scoreLabel.text = (comment.score - 1).commaRepresentation
        } else {
            self.scoreLabel.textColor = Config.colors.primaryFont
            self.scoreLabel.text = comment.score.commaRepresentation
        }
    }
    
    func didUpdateLikes(comment: RedditComment) {
        self.setupUpvoteDownvote(comment: comment)
    }
}
