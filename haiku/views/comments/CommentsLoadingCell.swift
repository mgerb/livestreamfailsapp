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
    
    let noCommentsLabel: UILabel = {
        let label = UILabel()
        label.text = "There doesn't seem to be anything here."
        label.font = Config.smallFont
        return label
    }()
    
    let loadingView: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        ai.startAnimating()
        return ai
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Config.colors.bg1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingView.removeFromSuperview()
        self.noCommentsLabel.removeFromSuperview()
    }
    
    func setLoading() {
        self.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    func setNoComments() {
        self.addSubview(self.noCommentsLabel)
        self.noCommentsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
}
