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
    
    /// Get the total height of this cell
    /// Heights
    /// - 5 top margin
    /// - 5 bottom margin
    /// - 15 header height
    /// - ? body height
    /// - 5 body top margin
    /// - 5 body bottom margin
    /// - 30 body horizontal margin
    public static func getHeight(redditComment: RedditComment) -> CGFloat {
        let width = UIScreen.main.bounds.width - (CommentsViewCell.calculateLeftMargin(depth: redditComment.depth) - 30)
        return 35 + (redditComment.body?.heightWithConstrainedWidth(width: width, font: Config.smallFont) ?? 0)
    }
    
    public var redditComment: RedditComment?

    var leftBorders: [UIView] = []

    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        self.addSubview(view)
        return view
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = Config.smallBoldFont
        label.textColor = Config.colors.blueLink
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = Config.smallBoldFont
        return label
    }()
    
    lazy var header: UIView = {
        let view = UIView()
        view.flex.paddingLeft(10).paddingRight(10).justifyContent(.spaceBetween).direction(.row).define { flex in
            flex.addItem(self.authorLabel)
            flex.addItem(self.scoreLabel)
        }
        
        self.bgView.addSubview(view)
        return view
    }()
    
    lazy var body: UITextView = {
        let view = UITextView()
        self.bgView.addSubview(view)
        view.isScrollEnabled = false
        view.isEditable = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.font = Config.smallFont
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate margin based on depth level of comment
        let marginLeft = CGFloat((self.redditComment?.depth ?? 0) * 10)
        self.bgView.pin.all().marginLeft(marginLeft).marginTop(5).marginBottom(5)
        
        self.header.pin.top().left().right().height(15)
        self.header.flex.layout()
        
        self.body.pin.below(of: self.header).left().right().bottom().margin(5, 15)

        for (index, border) in self.leftBorders.enumerated() {
            self.addSubview(border)
            let marginLeft = self.calculateBorderLeftMargin(depth: index)
            border.pin.top().bottom().left().width(1).marginLeft(marginLeft)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // remove left borders
        self.leftBorders.forEach { $0.removeFromSuperview() }
        self.leftBorders = []
    }
    
    func setRedditComment(c: RedditComment) {
        self.redditComment = c
        self.isHidden = c.collapsed

        self.body.text = c.body

        self.authorLabel.text = c.author
        self.authorLabel.flex.markDirty()
        
        self.scoreLabel.text = String(c.score ?? 0)
        self.scoreLabel.flex.markDirty()
        
        if c.depth > 0 {
            for i in 0...c.depth {
                if i == 0 {
                    continue
                }
                let view = UIView()
                view.backgroundColor = Config.colors.primaryLight1
                self.leftBorders.append(view)
            }
        }

        self.layoutSubviews()
    }
    
    static func calculateLeftMargin(depth: Int) -> CGFloat {
        return CGFloat((depth + 1) * 10)
    }
    
    func calculateBorderLeftMargin(depth: Int) -> CGFloat {
        return CommentsViewCell.calculateLeftMargin(depth: depth) + 5
    }

}
