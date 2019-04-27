//
//  TitleCollectionViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class TitleCollectionViewCell: UICollectionViewCell, RedditViewItemDelegate {

    /// height should be at least 70 if thumbnail exists (thumbnail height + padding)
    static func calculateHeightForWidth(redditViewItem: RedditViewItem, width: CGFloat) -> CGFloat {
        var cellOffsetWidth = TitleCollectionViewCell.padding * 2
        let showThumbnail = redditViewItem.failedToLoadVideo && redditViewItem.redditLink.previewUrl != nil
        
        if showThumbnail {
            cellOffsetWidth = cellOffsetWidth + 60
        }
        
        let height = redditViewItem.getTitleLabelText().heightWithConstrainedWidth(width: width - cellOffsetWidth, font: Config.regularFont) + 20
        
        let minHeight = TitleCollectionViewCell.thumbnailBounds + (TitleCollectionViewCell.padding * 2)
        if showThumbnail && height < minHeight {
            return minHeight
        }
        
        return height
    }
    
    static let thumbnailBounds = CGFloat(50)
    static let padding = CGFloat(10)
    
    var redditViewItem: RedditViewItem?

    lazy private var label: UILabel = {
        let label = Labels.new(font: .regular, color: .primary)
        label.numberOfLines = 0
        return label
    }()

    lazy private var nsfwLabel: UILabel = {
        let label = Labels.newAccent(color: .red)
        label.text = "NSFW"
        return label
    }()
    
    lazy private var thumbnail: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.redditViewItem?.delegate.add(delegate: self)
        
        DispatchQueue.main.async {
            self.setupThumbnail(item: item)
            self.label.text = item.getTitleLabelText()
            self.label.textColor = item.markedAsWatched && item.context == .home ? Config.colors.secondaryFont : Config.colors.primaryFont
            self.nsfwLabel.isHidden = !item.redditLink.over_18
        }
    }
    
    private func setupThumbnail(item: RedditViewItem) {
        self.thumbnail.isHidden = self.redditViewItem?.failedToLoadVideo == false
        
        if let urlString = self.redditViewItem?.redditLink.previewUrl {
            self.thumbnail.kf.setImage(with: URL(string: urlString.replaceEncoding()))
        }
        
        self.updateConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.nsfwLabel)
        self.contentView.addSubview(self.thumbnail)
        
        self.label.snp.makeConstraints { make in
            make.top.left.equalTo(self.contentView).offset(TitleCollectionViewCell.padding)
            make.right.equalTo(self.contentView).offset(-TitleCollectionViewCell.padding)
        }
        
        self.nsfwLabel.snp.makeConstraints { make in
            make.top.left.equalTo(self.contentView).offset(TitleCollectionViewCell.padding)
            make.height.equalTo(self.nsfwLabel.intrinsicContentSize.height + 3)
            make.width.equalTo(self.nsfwLabel.intrinsicContentSize.width + 5)
        }
        
        self.thumbnail.snp.makeConstraints { make in
            make.height.width.equalTo(TitleCollectionViewCell.thumbnailBounds)
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-TitleCollectionViewCell.padding)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if self.redditViewItem?.failedToLoadVideo == true && self.redditViewItem?.redditLink.previewUrl != nil {
            self.label.snp.updateConstraints { make in
                make.right.equalTo(self.contentView).offset(-((TitleCollectionViewCell.padding * 2) + TitleCollectionViewCell.thumbnailBounds))
            }
        } else {
            self.label.snp.updateConstraints { make in
                make.right.equalTo(self.contentView).offset(-TitleCollectionViewCell.padding)
            }
        }
        
        super.updateConstraints()
    }

    func didMarkAsWatched(redditViewItem: RedditViewItem) {
        self.label.textColor = redditViewItem.markedAsWatched && self.redditViewItem?.context == .home ? Config.colors.secondaryFont : Config.colors.primaryFont
    }
    
    func failedToLoadVideo(redditViewItem: RedditViewItem) {
        self.setupThumbnail(item: redditViewItem)
    }
}
