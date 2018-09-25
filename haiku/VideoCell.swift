//
//  VideoCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import Player
import XCDYouTubeKit

class VideoCell: UITableViewCell {
    
    var playerView: PlayerView?

    public func load(playerView: PlayerView) {
        self.selectionStyle = .none
        self.playerView = playerView
//        self.playerView?.isHidden = false
        if !self.contentView.subviews.contains(self.playerView!) {
            self.contentView.addSubview(self.playerView!)
            self.playerView!.snp.makeConstraints{ (make) -> Void in
                make.edges.equalTo(self.contentView)
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.playerView?.isHidden = true
        // prevent videos from showing up in other cells
        if self.contentView.subviews.contains(self.playerView!) {
            self.playerView?.player?.pause()
            self.playerView?.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
