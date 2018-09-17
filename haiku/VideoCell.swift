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
        self.playerView = playerView
        self.playerView?.isHidden = false
        self.selectionStyle = .none
        self.contentView.addSubview(self.playerView!)
        self.playerView!.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
    
    override func prepareForReuse() {
        // prevent videos from showing up in other cells
        if self.contentView.subviews.contains(self.playerView!) {
            self.playerView?.isHidden = true
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
