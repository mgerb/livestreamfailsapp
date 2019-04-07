//
//  CommentsHeaderCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/12/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsHeaderCell: UITableViewHeaderFooterView {
    
    var redditViewItem: RedditViewItem?
    
    lazy var label: UILabel = {
        let l = Labels.new(font: .small)
        l.text = "Comments"
        l.textAlignment = .center
        return l
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var topBorder = getBorder()
    lazy var bottomBorder = getBorder()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addSubview(bgView)
        self.bgView.addSubview(self.label)
        self.bgView.addSubview(self.topBorder)
        self.bgView.addSubview(self.bottomBorder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.bgView.pin.all()
        self.label.pin.all()

        topBorder.pin.top().left().right().height(1)
        bottomBorder.pin.bottom().left().right().height(1)
    }
    
    func setRedditViewItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem
    }
    
    func getBorder() -> UIView {
        let view = UIView()
        view.backgroundColor = Config.colors.bg2
        return view
    }
}
