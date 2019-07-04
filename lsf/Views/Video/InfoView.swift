//
//  InfoView.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class InfoView: UIView, RedditViewItemDelegate {

    var redditViewItem: RedditViewItem?
    let disposeBag = DisposeBag()
    let rxUnsubscribe = PublishSubject<Void>()
    
    lazy private var likeButton: UILabel = {
        return Icons.getLabel(icon: .heart, target: self, action: #selector(likeButtonAction))
    }()
    
    lazy private var moreButton: UILabel = {
        return Icons.getLabel(icon: .dots, target: self, action: #selector(moreButtonAction))
    }()
    
    lazy var scoreIcon = Icons.getLabel(icon: .arrowUp, target: self, action: #selector(scoreButtonAction))
    
    lazy var scoreLabel: UILabel = {
        let label = Labels.new(font: .small, target: self, action: #selector(scoreButtonAction))
        return label
    }()
    
    lazy var timeStampLabel: UILabel = {
        return Labels.new(font: .small, color: .secondary)
    }()
    
    lazy var commentsButton: UILabel = {
        let label = Labels.new(font: .small, target: self, action: #selector(commentsButtonAction))
        return label
    }()

    lazy private var commentBubble: UILabel = {
        return Icons.getLabel(icon: .comment, target: self, action: #selector(commentsButtonAction))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        self.addSubview(self.scoreIcon)
        self.addSubview(self.scoreLabel)
        self.addSubview(self.commentBubble)
        self.addSubview(self.commentsButton)
        self.addSubview(self.timeStampLabel)
        self.addSubview(self.moreButton)
        self.addSubview(self.likeButton)
        
        self.scoreIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(Config.BaseDimensions.cellPadding)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scoreIcon)
            make.left.equalTo(self.scoreIcon.snp.right)
        }
        
        self.commentBubble.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scoreLabel)
            make.left.equalTo(self.scoreLabel.snp.right).offset(10)
        }
        
        self.commentsButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.commentBubble)
            make.left.equalTo(self.commentBubble.snp.right).offset(5)
        }
        
        self.timeStampLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.commentsButton)
            make.left.equalTo(self.commentsButton.snp.right).offset(10)
        }
        
        self.likeButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scoreIcon)
            make.right.equalToSuperview().offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scoreIcon)
            make.right.equalTo(self.likeButton.snp.left).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRedditItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        self.redditViewItem?.delegate.add(delegate: self)
        self.rxUnsubscribe.onNext(())
        _ = self.redditViewItem?.favorited.takeUntil(self.rxUnsubscribe.asObservable()).subscribe(onNext: { favorited in
            self.setFavoriteButton(favorited)
        })
        
        DispatchQueue.main.async {
            self.scoreLabel.text = redditViewItem.redditLink.score.commaRepresentation
            self.commentsButton.text = redditViewItem.redditLink.num_comments.commaRepresentation
            self.timeStampLabel.text = redditViewItem.humanTimeStampExtended
            self.setupUpvoteDownvote(redditViewItem: redditViewItem)
        }
    }
    
    private func setFavoriteButton(_ favorited: Bool) {
        let color = favorited == true ? Config.colors.red : Config.colors.primaryFont
        let icon = favorited == true ? MyIconType.heartFill : MyIconType.heart
        self.likeButton.updateIcon(icon: icon, color: color)
    }
    
    
    private func animateFavoriteButton(button: UILabel) {
        // do popping animation on button and update color
        // TODO: see if possible to animate button color change
        let duration = 0.10
        UIView.animate(withDuration: duration, animations: {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: duration) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc func likeButtonAction() {
        self.animateFavoriteButton(button: self.likeButton)
        self.redditViewItem?.toggleFavorite()
    }
    
    @objc func moreButtonAction() {
        if let redditViewItem = self.redditViewItem {
            Subjects.shared.moreButtonAction.onNext(redditViewItem)
        }
    }
    
    @objc func commentsButtonAction() {
        if let redditViewItem = self.redditViewItem {
            Subjects.shared.showCommentsAction.onNext((redditViewItem, false))
        }
    }
    
    @objc func scoreButtonAction() {
        if let redditViewItem = self.redditViewItem {
            self.animateFavoriteButton(button: self.scoreIcon)
            redditViewItem.upvote()
            Util.hapticFeedback()
        }
    }
    
    func setupUpvoteDownvote(redditViewItem: RedditViewItem) {
        if redditViewItem.redditLink.likes == true {
            self.scoreLabel.textColor = Config.colors.upvote
            self.scoreIcon.textColor = Config.colors.upvote
            self.scoreLabel.text = (redditViewItem.redditLink.score + 1).commaRepresentation
        } else if redditViewItem.redditLink.likes == false {
            self.scoreLabel.textColor = Config.colors.downvote
            self.scoreIcon.textColor = Config.colors.downvote
            self.scoreLabel.text = (redditViewItem.redditLink.score - 1).commaRepresentation
        } else {
            self.scoreLabel.textColor = Config.colors.primaryFont
            self.scoreIcon.textColor = Config.colors.primaryFont
            self.scoreLabel.text = redditViewItem.redditLink.score.commaRepresentation
        }
    }

    func failedToLoadVideo(redditViewItem: RedditViewItem) {
    }
    
    func didMarkAsWatched(redditViewItem: RedditViewItem) {
    }
    
    func didUpdateLikes(redditViewItem: RedditViewItem) {
        self.setupUpvoteDownvote(redditViewItem: redditViewItem)
    }
}
