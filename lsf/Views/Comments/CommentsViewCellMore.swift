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
        return l
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.top.left.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding)
            make.bottom.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.label.snp.remakeConstraints { make in
            make.top.equalTo(self.contentView).offset(Config.BaseDimensions.cellPadding).priorityLow()
            make.bottom.right.equalTo(self.contentView).offset(-Config.BaseDimensions.cellPadding).priorityLow()
            make.left.equalTo(self.contentView).offset((c.depth * 10) + Config.BaseDimensions.cellPadding)
        }
    }
}
