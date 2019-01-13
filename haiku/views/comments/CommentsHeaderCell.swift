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
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.textColor = Config.colors.primaryFont
        l.text = "Comments"
        l.textAlignment = .center
        l.font = Config.smallFont
        return l
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(bgView)
        self.bgView.addSubview(self.label)
        
        self.bgView.pin.all()
        self.label.pin.all()
        
        let topBorder = getBorder()
        let bottomBorder = getBorder()
        self.bgView.addSubview(topBorder)
        self.bgView.addSubview(bottomBorder)
        
        topBorder.pin.top().left().right().height(1)
        bottomBorder.pin.bottom().left().right().height(1)
    }
    
    func getBorder() -> UIView {
        let view = UIView()
        view.backgroundColor = Config.colors.primaryLight2
        return view
    }
}
