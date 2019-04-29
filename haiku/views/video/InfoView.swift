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

class InfoView: UIView, VideoView {
    
    var redditViewItem: RedditViewItem?
    let disposeBag = DisposeBag()
    let rxUnsubscribe = PublishSubject<Void>()
    
    lazy private var likeButton: UILabel = {
        return Icons.getLabel(icon: .heart, target: self, action: #selector(likeButtonAction))
    }()
    
    lazy private var moreButton: UILabel = {
        return Icons.getLabel(icon: .dots, target: self, action: #selector(moreButtonAction))
    }()
    
    let scoreLabel: UILabel = {
        let label = Labels.new(font: .small)
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let timeStampLabel: UILabel = {
        return Labels.new(font: .small, color: .secondary)
    }()
    
    lazy private var commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(Config.colors.primaryFont, for: .normal)
        button.titleLabel?.font = Config.smallFont
        // set to nearly zero for left/right as 0 makes it use default values...
        button.contentEdgeInsets = UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1)
        button.addTarget(self, action: #selector(commentsButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy private var commentBubble: UILabel = {
        return Icons.getLabel(icon: .comment, target: self, action: #selector(commentsButtonAction))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let upIcon = Icons.getLabel(icon: .arrowUp)
        
        self.addSubview(upIcon)
        self.addSubview(self.scoreLabel)
        self.addSubview(self.commentBubble)
        self.addSubview(self.commentsButton)
        self.addSubview(self.timeStampLabel)
        self.addSubview(self.moreButton)
        self.addSubview(self.likeButton)
        
        upIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(Config.BaseDimensions.cellPadding)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(upIcon)
            make.left.equalTo(upIcon.snp.right)
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
            make.top.bottom.equalTo(upIcon)
            make.right.equalToSuperview().offset(-Config.BaseDimensions.cellPadding)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(upIcon)
            make.right.equalTo(self.likeButton.snp.left).offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRedditItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
        _ = self.redditViewItem?.favorited.takeUntil(self.rxUnsubscribe.asObservable()).subscribe(onNext: { favorited in
            self.setFavoriteButton(favorited)
        })
        
        DispatchQueue.main.async {
            self.scoreLabel.text = redditViewItem.redditLink.score.commaRepresentation
            self.commentsButton.setTitle(redditViewItem.redditLink.num_comments.commaRepresentation, for: .normal)
            self.timeStampLabel.text = redditViewItem.humanTimeStampExtended
        }
    }
    
    private func setFavoriteButton(_ favorited: Bool) {
        let color = favorited == true ? Config.colors.red : Config.colors.primaryFont
        let icon = favorited == true ? MyIconType.heartFill : MyIconType.heart
        self.likeButton.updateIcon(icon: icon, color: color)
    }
    
    private func animateFavoriteButton() {
        // do popping animation on button and update color
        // TODO: see if possible to animate button color change
        let duration = 0.10
        UIView.animate(withDuration: duration, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: duration) {
                self.likeButton.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc func likeButtonAction() {
        self.animateFavoriteButton()
        self.redditViewItem?.toggleFavorite()
    }
    
    @objc func moreButtonAction() {
        if let redditViewItem = self.redditViewItem {
            Subjects.shared.moreButtonAction.onNext(redditViewItem)
        }
    }
    
    @objc func commentsButtonAction() {
        if let redditViewItem = self.redditViewItem {
            Subjects.shared.showCommentsAction.onNext(redditViewItem)
        }
    }
}
