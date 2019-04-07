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
import FlexLayout

class CommentsViewCell: UITableViewCell {
    
    public var redditComment: RedditComment?

    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = Config.colors.bg1
        return view
    }()
    
    lazy var bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = Config.colors.bg2
        return view
    }()

    var leftBorders: [UIView] = []

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // set light gray highlight color
        let bgColorView = UIView()
        bgColorView.backgroundColor = Config.colors.bg3
        self.selectedBackgroundView = bgColorView
        self.backgroundColor = Config.colors.bg1
        
        self.addSubview(self.bgView)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // calculate margin based on depth level of comment
        let marginLeft = CGFloat((self.redditComment?.depth ?? 0) * 10)
        self.bgView.pin.all().marginLeft(marginLeft).marginTop(10).marginBottom(10)

        for (index, border) in self.leftBorders.enumerated() {
            border.pin.left().top().bottom().width(0.5).marginLeft(CGFloat((index + 1) * 10))
        }

        if self.redditComment?.depth == 0 {
            self.bottomBorder.pin.left().top().right().height(0.25)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bottomBorder.removeFromSuperview()
        self.removeLeftBorders()
    }
    
    func addLeftBorders(depth: Int) {
        for _ in 0...depth - 1 {
            let border = UIView()
            border.backgroundColor = Config.colors.bg3
            self.leftBorders.append(border)
            self.addSubview(border)
        }
    }

    func removeLeftBorders() {
        self.leftBorders.forEach { $0.removeFromSuperview() }
        self.leftBorders = []
    }

    func setRedditComment(c: RedditComment) {
        self.redditComment = c
        self.isHidden = c.isHidden
        if c.depth > 0 {
            self.addLeftBorders(depth: c.depth)
        }
    }
    
    static func calculateLeftMargin(depth: Int) -> CGFloat {
        return CGFloat((depth + 1) * 10)
    }
    
    func calculateBorderLeftMargin(depth: Int) -> CGFloat {
        return CommentsViewCell.calculateLeftMargin(depth: depth) + 5
    }
}
