//
//  CommentBody.swift
//  lsf
//
//  Created by Mitchell Gerber on 7/1/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class CommentsBodyView: UIView {
    
    lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5
        return view
    }()
    
    lazy var headerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = UIStackView.Distribution.equalSpacing
        return view
    }()
    
    lazy var authorContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        return view
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
    
    lazy var authorLabel = Labels.new(font: .regularBold)
    lazy var scoreLabel = Labels.new(color: .secondary)
    lazy var timeStampLabel = Labels.new(color: .secondary)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.mainStackView)
        
        self.mainStackView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(Config.BaseDimensions.cellPadding)
            make.bottom.right.equalToSuperview().offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.authorContainer.addArrangedSubview(self.authorLabel)
        self.authorContainer.addArrangedSubview(self.timeStampLabel)
        self.headerStackView.addArrangedSubview(self.authorContainer)
        self.headerStackView.addArrangedSubview(self.scoreLabel)
        self.mainStackView.addArrangedSubview(self.headerStackView)
        self.mainStackView.addArrangedSubview(self.body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRedditComment(comment: RedditComment) {
        self.body.isHidden = comment.isHidden || comment.isCollapsed || comment.isDeleted
        self.body.attributedText = comment.htmlBody
        self.authorLabel.textColor = comment.author == RedditService.shared.user?.name ? Config.colors.upvote : Config.colors.primaryFont
        self.authorLabel.text = comment.author
        self.timeStampLabel.text = "· " + comment.humanTimeStamp
        self.scoreLabel.text = comment.score.commaRepresentation
        
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
}
