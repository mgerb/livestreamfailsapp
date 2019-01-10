//
//  CommentViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import PinLayout

class CommentViewCell: UICollectionViewCell {
    
    public var redditComment: RedditComment?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.backgroundColor = .white
        let label = UILabel()
        label.text = "test123"
        
        self.addSubview(label)

        label.pin.all()
    }
}
