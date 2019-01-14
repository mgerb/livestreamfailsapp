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
        let l = UILabel()
        l.font = Config.smallerFont
        l.textColor = Config.colors.blueLink
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
    
    override func setRedditComment(c: RedditComment) {
        super.setRedditComment(c: c)
        self.label.text = "Load More (\(c.children?.count ?? 0))"
        self.layoutSubviews()
    }
}
