//
//  MyIconLabel.swift
//  haiku
//
//  Created by Mitchell Gerber on 5/9/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MyIconLabel: UIStackView {
    var text: String? {
        didSet {
            self.linkLabel.text = self.text
        }
    }

    private var linkIcon: UILabel?

    private lazy var linkLabel: UILabel = {
        let label = Labels.new(font: .small)
        label.numberOfLines = 1
        return label
    }()
    
    convenience init(icon: MyIconType, color: UIColor = Config.colors.primaryFont) {
        self.init()
        self.linkIcon = Icons.getLabel(icon: icon, size: Config.regularFont.pointSize, color: color)
        self.linkLabel.textColor = color
        self.addArrangedSubview(self.linkIcon!)
        self.addArrangedSubview(self.linkLabel)
        
        self.linkIcon!.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
