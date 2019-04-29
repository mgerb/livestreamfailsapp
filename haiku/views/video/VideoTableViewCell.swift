//
//  VideoTableViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class VideoTableViewCell: UITableViewCell, VideoView, RedditViewItemDelegate {
    
    // TODO:
    static func getEstimatedHeight() -> CGFloat {
        return 304
    }

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    lazy var titleView: TitleView = {
        let view = TitleView()
        return view
    }()
    
    lazy var playerView: PlayerView = {
        let view = PlayerView()
        return view
    }()
    
    lazy var infoView: InfoView = {
        let view = InfoView()
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.titleView)
        self.stackView.addArrangedSubview(self.playerView)
        self.stackView.addArrangedSubview(self.infoView)

        self.stackView.snp.makeConstraints { make in
            make.top.right.left.bottom.equalToSuperview()
        }
        
        self.playerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(self.stackView.snp.width).multipliedBy(Float(9) / Float(16)).priorityRequired()
        }
    }

    func setRedditItem(redditViewItem: RedditViewItem) {
        redditViewItem.delegate.add(delegate: self)
        self.titleView.setRedditItem(redditViewItem: redditViewItem)
        self.playerView.setRedditItem(redditViewItem: redditViewItem)
        self.playerView.isHidden = redditViewItem.failedToLoadVideo
        self.infoView.setRedditItem(redditViewItem: redditViewItem)
    }

    func failedToLoadVideo(redditViewItem: RedditViewItem) {
        self.playerView.isHidden = redditViewItem.failedToLoadVideo
    }
    
    func didMarkAsWatched(redditViewItem: RedditViewItem) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
