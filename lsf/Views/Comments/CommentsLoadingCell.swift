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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.loadingView)
        self.contentView.addSubview(self.noCommentsLabel)
        
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(50)
            make.bottom.equalTo(self.contentView).offset(-50)
            make.centerX.equalTo(self.contentView)
        }
        
        self.noCommentsLabel.snp.makeConstraints { make in
            make.center.equalTo(self.loadingView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLoading() {
        self.noCommentsLabel.isHidden = true
        self.loadingView.isHidden = false
    }
    
    func setNoComments() {
        self.loadingView.isHidden = true
        self.noCommentsLabel.isHidden = false
    }
}
