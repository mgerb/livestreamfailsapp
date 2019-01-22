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
    var leftBorderColor: UIColor?

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
    
    lazy var leftBorder: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // set light gray highlight color
        let bgColorView = UIView()
        bgColorView.backgroundColor = Config.colors.bg2
        self.selectedBackgroundView = bgColorView
        self.backgroundColor = Config.colors.bg1
        
        self.addSubview(self.bgView)
        self.addSubview(self.bottomBorder)
        self.addSubview(self.leftBorder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // These two override methods are to prevent the left border
    // from being hidden when the cell is highlighted/selected.
    // https://stackoverflow.com/questions/6745919/uitableviewcell-subview-disappears-when-cell-is-selected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.leftBorder.backgroundColor = self.leftBorderColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.leftBorder.backgroundColor = self.leftBorderColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate margin based on depth level of comment
        let marginLeft = CGFloat((self.redditComment?.depth ?? 0) * 10)
        self.bgView.pin.all().marginLeft(marginLeft).marginTop(10).marginBottom(10)
        self.bottomBorder.pin.left().bottom().right().height(1).marginLeft(marginLeft + 10)
        self.leftBorder.pin.left().top().bottom().width(2).marginLeft(marginLeft).marginTop(5).marginBottom(5)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setRedditComment(c: RedditComment) {
        self.redditComment = c
        self.isHidden = c.isHidden
        
        self.leftBorder.isHidden = c.depth == 0
        self.leftBorderColor = c.getLeftBorderColor()
        self.leftBorder.backgroundColor = self.leftBorderColor
    }
    
    static func calculateLeftMargin(depth: Int) -> CGFloat {
        return CGFloat((depth + 1) * 10)
    }
    
    func calculateBorderLeftMargin(depth: Int) -> CGFloat {
        return CommentsViewCell.calculateLeftMargin(depth: depth) + 5
    }
}
