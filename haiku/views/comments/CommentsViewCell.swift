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
        let width = UIScreen.main.bounds.width - CGFloat(redditComment.depth * 10) - 30
        return 35 + (redditComment.htmlBody?.height(containerWidth: width) ?? 0)
    }
    
    public var redditComment: RedditComment?

    var leftBorders: [UIView] = []

    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        self.addSubview(view)
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

        if c.depth > 0 {
            for i in 0...c.depth {
                if i == 0 {
                    continue
                }
                let view = UIView()
                view.backgroundColor = Config.colors.primaryLight2
                self.leftBorders.append(view)
            }
        }
    }
    
    static func calculateLeftMargin(depth: Int) -> CGFloat {
        return CGFloat((depth + 1) * 10)
    }
    
    func calculateBorderLeftMargin(depth: Int) -> CGFloat {
        return CommentsViewCell.calculateLeftMargin(depth: depth) + 5
    }
}
