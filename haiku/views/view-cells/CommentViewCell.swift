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
    
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.backgroundColor = .white
        self.addSubview(self.label)
        self.label.pin.all()
    }
    
    func setRedditComment(c: RedditComment) {
        self.redditComment = c
        self.label.text = c.author
    }
}
