//
//  CommentsLoadingCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/20/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView_iOS

class CommentsLoadingCell: UITableViewCell {
    
    lazy var loadingView: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60), type: .ballScaleMultiple, color: Config.colors.blueLink, padding: 0)
        view.alpha = 0.5
        view.startAnimating()
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
}
