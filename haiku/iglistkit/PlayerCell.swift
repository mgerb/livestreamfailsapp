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
    
    lazy private var playerView: MyPlayerView = {
        let view = MyPlayerView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tap)
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy private var thumbnail: UIImageView = {
        let view = UIImageView()
        self.contentView.addSubview(view)
        view.kf.setImage(with: URL(fileURLWithPath: "https://i.ytimg.com/vi/zUJZ8fxaW3w/default.jpg"))
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerView.frame = contentView.bounds
        self.thumbnail.frame = contentView.bounds
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.playerView.playerLayer.player = player
    }
    
//    func setThumbnail(_ view: UIImageView) {
//        self.thumbnail = view
//    }
    
    @objc func onTap() {
        GlobalPlayer.shared.onPlayerTap(self.playerView.player!)
    }
}
