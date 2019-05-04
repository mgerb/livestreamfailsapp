//
//  TitleView.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class TitleView: UIView, VideoView, RedditViewItemDelegate {

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = UIStackViewDistribution.fill
        view.alignment = .top
        view.spacing = CGFloat(Config.BaseDimensions.cellPadding)
        return view
    }()
    
    lazy var labelContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = Labels.new()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nsfwLabel: UILabel = {
        let label = Labels.newAccent(color: .red)
        label.text = "NSFW"
        return label
    }()
    
    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.stackView)
        self.labelContainerView.addSubview(self.titleLabel)
        self.labelContainerView.addSubview(self.nsfwLabel)
        
        self.stackView.addArrangedSubview(self.labelContainerView)
        self.stackView.addArrangedSubview(self.thumbnail)
        
        self.thumbnail.snp.makeConstraints { make in
            make.height.width.equalTo(50).priority(999)
        }

        self.stackView.snp.makeConstraints { make in
            make.top.left.equalTo(self).offset(Config.BaseDimensions.cellPadding).priority(1000)
            make.bottom.right.equalTo(self).offset(-Config.BaseDimensions.cellPadding).priority(1000)
        }
        

        self.titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.nsfwLabel.snp.makeConstraints { make in
            make.top.left.equalTo(self.titleLabel)
            make.height.equalTo(self.nsfwLabel.intrinsicContentSize.height + 3)
            make.width.equalTo(self.nsfwLabel.intrinsicContentSize.width + 5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRedditItem(redditViewItem: RedditViewItem) {
        redditViewItem.delegate.add(delegate: self)
        self.titleLabel.text = redditViewItem.getTitleLabelText()
        self.nsfwLabel.isHidden = !redditViewItem.redditLink.over_18
        self.thumbnail.isHidden = !redditViewItem.failedToLoadVideo
        self.setTitleLabelColor(redditViewItem: redditViewItem)

        if let previewUrl = redditViewItem.redditLink.previewUrl {
            self.thumbnail.kf.setImage(with: URL(string: previewUrl.replaceEncoding()))
        }
        
        self.needsUpdateConstraints()
    }
    
    func failedToLoadVideo(redditViewItem: RedditViewItem) {
//        self.thumbnail.isHidden = !redditViewItem.failedToLoadVideo
    }
    
    func didMarkAsWatched(redditViewItem: RedditViewItem) {
        self.setTitleLabelColor(redditViewItem: redditViewItem)
    }
    
    func setTitleLabelColor(redditViewItem: RedditViewItem) {
        self.titleLabel.textColor = redditViewItem.markedAsWatched && redditViewItem.context == .home ? Config.colors.secondaryFont : Config.colors.primaryFont
    }
}