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
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = Config.colors.bg1
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.addSubview(self.bgView)
        self.bgView.addSubview(self.loadingView)
        self.bgView.addSubview(self.noCommentsLabel)
        
        self.bgView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.loadingView.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(self.bgView)
        }
        
        self.noCommentsLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(self)
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
