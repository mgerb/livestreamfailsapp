//
//  SortBarSectionController.swift
//  haiku
//
//  Created by Mitchell Gerber on 2/17/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import IGListKit
import PinLayout
import FlexLayout

protocol SortBarDelegate {
    func sortBarDidUpdate(sortBy: RedditPostSortBy)
    func activeRedditPostSortBy() -> RedditPostSortBy
}

class SortBarSectionController: ListSectionController, ListDisplayDelegate, ListWorkingRangeDelegate {

    var delegate: SortBarDelegate?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: SortBarCollectionViewCell.height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: SortBarCollectionViewCell.self, for: self, at: index) as! SortBarCollectionViewCell
        cell.delegate = self.delegate
        return cell
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
    }
}

class SortBarCollectionViewCell: UICollectionViewCell {
    
    static let height = CGFloat(40)
    var delegate: SortBarDelegate?

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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

        self.scrollView.contentSize = CGSize(width: self.flexView.frame.width + 20, height: SortBarCollectionViewCell.height)
        
        self.updateSelectedButtons()
    }

    @objc func buttonPress(sender: UIButton) {
        if let title = sender.titleLabel?.text {
            if self.delegate?.activeRedditPostSortBy().rawValue == title.lowercased() {
                return
            }
            
            if let sortBy = RedditPostSortBy(rawValue: title.lowercased()) {
                self.delegate?.sortBarDidUpdate(sortBy: sortBy)
                self.updateSelectedButtons()
            }
        }
    }
    
    private func updateSelectedButtons() {
        self.buttons.forEach {
            if $0.titleLabel?.text?.lowercased() == self.delegate?.activeRedditPostSortBy().rawValue {
                $0.backgroundColor = Config.colors.blue
                $0.setTitleColor(Config.colors.white, for: .normal)
            } else {
                $0.backgroundColor = .clear
                $0.setTitleColor(Config.colors.primaryFont, for: .normal)
            }
        }
    }
}
