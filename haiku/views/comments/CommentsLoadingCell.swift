//
//  CommentsLoadingCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/20/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsLoadingCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Config.colors.bg1
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        ai.startAnimating()
        self.addSubview(ai)
        ai.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
}
