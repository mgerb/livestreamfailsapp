//
//  CommentsViewCellContent.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CommentsViewCellContent: CommentsViewCell, RedditCommentDelegate {

    lazy var bodyView = CommentsBodyView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.bodyView)
        self.bodyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRedditComment(c: RedditComment) {
        super.setRedditComment(c: c)
        c.delegate = self
        self.bodyView.setRedditComment(comment: c)
        self.contentView.alpha = c.isCollapsed ? 0.3 : 1
        
        self.bodyView.snp.remakeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(((c.depth - 1) * 10) + Config.BaseDimensions.cellPadding)
        }
    }

    func didUpdateLikes(comment: RedditComment) {
        self.bodyView.setRedditComment(comment: comment)
    }
}
