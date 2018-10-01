//
//  LabelCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import AVKit;
import AVFoundation;
import Kingfisher

class PlayerCell: UICollectionViewCell {
    
    lazy public var playerView: MyPlayerView = {
        let view = MyPlayerView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints{(make) -> Void in
            make.edges.equalTo(self)
        }
        view.isHidden = true
        return view
    }()
    
    private var playerItem: AVPlayerItem?
    var thumbnail = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.thumbnail)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.contentView.addGestureRecognizer(tap)
    }

    func setPlayerItem(_ item: AVPlayerItem?) {
        self.playerItem = item
        if item != nil && item === GlobalPlayer.shared.player.currentItem {
            self.playerView.playerLayer.player = GlobalPlayer.shared.player
            self.thumbnail.isHidden = true
            self.playerView.isHidden = false
        } else {
            self.playerView.playerLayer.player = nil
            self.thumbnail.isHidden = false
            self.playerView.isHidden = true
        }
    }
    
    func setThumbnail(_ view: UIImageView) {
        self.thumbnail = view
        self.contentView.addSubview(self.thumbnail)
        self.thumbnail.snp.makeConstraints{(make) -> Void in
            make.edges.equalTo(self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.contentView.contains(self.thumbnail) {
            self.thumbnail.removeFromSuperview()
        }
    }
    
    @objc func onTap() {
        if let item = self.playerItem {
            GlobalPlayer.shared.replaceItem(item)
            self.playerView.playerLayer.player = GlobalPlayer.shared.player
            self.thumbnail.isHidden = true
            self.playerView.isHidden = false
        }
    }
}
