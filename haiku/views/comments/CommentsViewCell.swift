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
        view.backgroundColor = Config.colors.dark2
        self.addSubview(view)
        return view
    }()
    
    lazy var bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = Config.colors.dark1
        self.addSubview(view)
        return view
    }()
    
    lazy var leftBorder: UIView = {
        let view = UIView()
        view.layer.insertSublayer(self.leftBorderGradient, at: 0)
        self.bgView.addSubview(view)
        return view
    }()
    
    lazy var leftBorderGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hexString: "#fc00ff").cgColor, UIColor(hexString: "#00dbde").cgColor]
        return gradient
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // set light gray highlight color
        self.selectionStyle = .gray
        let bgColorView = UIView()
        bgColorView.backgroundColor = Config.colors.dark1
        self.selectedBackgroundView = bgColorView
        self.backgroundColor = Config.colors.dark2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate margin based on depth level of comment
        let marginLeft = CGFloat((self.redditComment?.depth ?? 0) * 10)
        self.bgView.pin.all().marginLeft(marginLeft).marginTop(5).marginBottom(5)
        self.bottomBorder.pin.left().bottom().right().height(1).marginLeft(marginLeft + 10)
        self.leftBorder.pin.left().top().bottom().width(2).margin(5, 0)
        self.leftBorderGradient.frame = self.leftBorder.bounds
        self.leftBorderGradient.cornerRadius = 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setRedditComment(c: RedditComment) {
        self.redditComment = c
        self.isHidden = c.isHidden
        self.leftBorder.isHidden = c.depth == 0
    }
    
    static func calculateLeftMargin(depth: Int) -> CGFloat {
        return CGFloat((depth + 1) * 10)
    }
    
    func calculateBorderLeftMargin(depth: Int) -> CGFloat {
        return CommentsViewCell.calculateLeftMargin(depth: depth) + 5
    }
}
