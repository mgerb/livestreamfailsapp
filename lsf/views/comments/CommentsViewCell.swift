//
//  CommentViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewCell: UITableViewCell {
    
    public var redditComment: RedditCommentProtocol?

    var leftBorders: [UIView] = []

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // set light gray highlight color
        let bgColorView = UIView()
        bgColorView.backgroundColor = Config.colors.bg3
        self.selectedBackgroundView = bgColorView
        self.backgroundColor = Config.colors.bg1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// KEEP THIS TWO METHODS in case we need them in the future
    /// CURRENTLY UNUSED
    // These two override methods are to prevent the left border
    // from being hidden when the cell is highlighted/selected.
    // https://stackoverflow.com/questions/6745919/uitableviewcell-subview-disappears-when-cell-is-selected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
//            self.leftBorder.backgroundColor = self.leftBorderColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
//            self.leftBorder.backgroundColor = self.leftBorderColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeLeftBorders()
    }
    
    func addLeftBorders(depth: Int) {
        for index in 1...depth {
            let border = UIView()
            border.backgroundColor = Config.colors.bg3
            self.leftBorders.append(border)
            self.contentView.addSubview(border)

            border.snp.makeConstraints { make in
                make.top.bottom.equalTo(self.contentView)
                make.left.equalTo(self.contentView).offset(index * 10)
                make.width.equalTo(0.5)
            }
        }
    }

    func removeLeftBorders() {
        self.leftBorders.forEach { $0.removeFromSuperview() }
        self.leftBorders = []
    }

    func setRedditComment(c: RedditCommentProtocol) {
        self.redditComment = c
        self.isHidden = c.isHidden
        if c.depth > 0 {
            self.addLeftBorders(depth: c.depth)
        }
    }
}
