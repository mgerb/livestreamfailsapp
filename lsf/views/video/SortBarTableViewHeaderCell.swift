//
//  SortBarTableViewHeaderCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol SortBarTableViewHeaderCellDelegate {
    func sortBarDidUpdate(sortBy: RedditLinkSortBy)
    func activeRedditLinkSortBy() -> RedditLinkSortBy
}

class SortBarTableViewHeaderCell: UITableViewHeaderFooterView {
    
    static let height = CGFloat(40)
    var delegate: SortBarTableViewHeaderCellDelegate?
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 30
        return view
    }()
    
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
            button.setTitleColor(Config.colors.primaryFont, for: .normal)
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(self.buttonPress), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            return button
        }
    }()

    lazy var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
        self.scrollView.addSubview(self.selectedView)
        
        self.buttons.forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }

        self.scrollView.contentSize = CGSize(width: self.stackView.frame.width + 20, height: SortBarTableViewHeaderCell.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        self.buttons.forEach { btn in
            if btn.titleLabel?.text?.lowercased() == self.delegate?.activeRedditLinkSortBy().rawValue {
                self.selectedView.snp.remakeConstraints { make in
                    make.left.equalTo(btn).offset(-10)
                    make.right.equalTo(btn).offset(10)
                    make.bottom.equalToSuperview()
                    make.height.equalTo(2)
                }

                UIView.animate(withDuration: 0.2, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
    }
}
