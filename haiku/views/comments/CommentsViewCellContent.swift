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
    
    /// Get the total height of this cell
    /// Heights
    /// - 5 top margin
    /// - 5 bottom margin
    /// - 15 header height
    /// - ? body height
    /// - 5 body top margin
    /// - 5 body bottom margin
    /// - 20 body horizontal margin
    public static func getHeight(redditComment: RedditComment) -> CGFloat {
        let width = UIScreen.main.bounds.width - CGFloat(redditComment.depth * 10) - 20
        return 35 + (redditComment.htmlBody?.height(containerWidth: width) ?? 0)
    }
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = Config.smallBoldFont
        label.textColor = Config.colors.font1
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = Config.smallFont
        label.textColor = Config.colors.font2
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
    
    lazy var body: TapThroughTextView = {
        let view = TapThroughTextView()
        self.bgView.addSubview(view)
        view.backgroundColor = Config.colors.bg1
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
        self.body.pin.below(of: self.header).left().right().bottom().margin(5, 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setRedditComment(c: RedditComment) {
        super.setRedditComment(c: c)

        self.bgView.alpha = c.isCollapsed ? 0.3 : 1
        self.body.isHidden = c.isHidden || c.isCollapsed || c.isDeleted
        self.body.attributedText = c.htmlBody

        self.authorLabel.text = c.author
        self.authorLabel.flex.markDirty()
        
        self.scoreLabel.text = String(c.score ?? 0)
        self.scoreLabel.flex.markDirty()

        self.layoutSubviews()
    }
}
