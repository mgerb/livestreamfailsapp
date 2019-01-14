//
//  CommentsViewCellContent.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewCellContent: CommentsViewCell {
    
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
        
        self.header.pin.top().left().right().height(15)
        self.header.flex.layout()
        self.body.pin.below(of: self.header).left().right().bottom().margin(5, 15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setRedditComment(c: RedditComment) {
        super.setRedditComment(c: c)
        
        self.isHidden = c.collapsed
        
        self.body.attributedText = c.htmlBody

        self.authorLabel.text = c.author
        self.authorLabel.flex.markDirty()
        
        self.scoreLabel.text = String(c.score ?? 0)
        self.scoreLabel.flex.markDirty()

        self.layoutSubviews()
    }
}
