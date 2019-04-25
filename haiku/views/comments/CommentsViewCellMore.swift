//
//  MoreCommentsViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewCellMore: CommentsViewCell {
    
    lazy var label: UILabel = {
        let l = Labels.new(font: .small, color: .blue)
        self.bgView.addSubview(l)
        return l
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.pin.all().marginLeft(15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setRedditComment(c: RedditMore) {
        super.setRedditComment(c: c)
        var text = ""
        
        if c.isContinueThread {
            text = "Continue thread..."
        } else {
            text = "Load More (\(c.children.count))"
        }

        self.label.text = text
        self.layoutSubviews()
    }
}
