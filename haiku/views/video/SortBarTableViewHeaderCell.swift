//
//  SortBarTableViewHeaderCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

protocol SortBarTableViewHeaderCellDelegate {
    func sortBarDidUpdate(sortBy: RedditLinkSortBy)
    func activeRedditLinkSortBy() -> RedditLinkSortBy
}

class SortBarTableViewHeaderCell: UITableViewHeaderFooterView {
    
    static let height = CGFloat(40)
    var delegate: SortBarTableViewHeaderCellDelegate?
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    let buttonList = ["Hot", "New", "Rising", "Controversial", "Top"]
    
    lazy var buttons: [UIButton] = {
        return self.buttonList.map {
            let button = UIButton()
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = Config.regularBoldFont
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(self.buttonPress), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            return button
        }
    }()
    
    lazy var flexView: UIView = {
        let view = UIView()
        
        view.flex.direction(.row).alignItems(.center).define { flex in
            for (index, button) in self.buttons.enumerated() {
                let newItem = flex.addItem(button).height(25)
                if index != 0 {
                    newItem.marginLeft(30)
                }
            }
        }
        
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.flexView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollView.pin.all()
        self.flexView.pin.all().marginLeft(10).marginRight(10)
        
        self.flexView.flex.layout(mode: .adjustWidth)
        
        self.scrollView.contentSize = CGSize(width: self.flexView.frame.width + 20, height: SortBarTableViewHeaderCell.height)
        
        self.updateSelectedButtons()
    }
    
    @objc func buttonPress(sender: UIButton) {
        if let title = sender.titleLabel?.text?.lowercased() {
            if title != RedditLinkSortBy.top.rawValue && self.delegate?.activeRedditLinkSortBy().rawValue == title {
                return
            }
            
            if let sortBy = RedditLinkSortBy(rawValue: title) {
                self.delegate?.sortBarDidUpdate(sortBy: sortBy)
                self.updateSelectedButtons()
            }
        }
    }
    
    private func updateSelectedButtons() {
        self.buttons.forEach {
            if $0.titleLabel?.text?.lowercased() == self.delegate?.activeRedditLinkSortBy().rawValue {
                $0.backgroundColor = Config.colors.blue
                $0.setTitleColor(Config.colors.white, for: .normal)
            } else {
                $0.backgroundColor = .clear
                $0.setTitleColor(Config.colors.primaryFont, for: .normal)
            }
        }
    }
}
