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

    public func load(playerView: PlayerView) {
        self.contentView.addSubview(playerView)
        playerView.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
