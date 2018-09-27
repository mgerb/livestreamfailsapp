//
//  TitleCollectionViewCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import SnapKit

class TitleCollectionViewCell: UICollectionViewCell {
    
    
    lazy private var label: UILabel = {
        let label = UILabel()
        self.contentView.addSubview(label)
        return label
    }()
    
    var text: String? {
        didSet {
            self.label.text = self.text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.centerY.equalTo(self)
        }
    }
}
