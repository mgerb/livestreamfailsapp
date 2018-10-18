//
//  DisplaySectionController.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import IGListKit
import UIKit
import AVKit

final class DisplaySectionController: ListSectionController, ListDisplayDelegate, ListWorkingRangeDelegate {


    public var redditPost: RedditPost!

    override init() {
        super.init()
        displayDelegate = self
        workingRangeDelegate = self
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 3
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        switch index {
        case 0:
            let cellHorizontalPadding = CGFloat(15)
            var size = CGSize(width: width, height: "blankstring".heightWithConstrainedWidth(width: width - cellHorizontalPadding, font: Config.defaultFont) + 20)
            if self.redditPost.expandTitle {
                size.height = self.redditPost.title.heightWithConstrainedWidth(width: width - cellHorizontalPadding, font: Config.defaultFont) + 20
            }
            return size
        case 1:
            let height = (width * 9 / 16)
            return CGSize(width: width, height: height)
        case 2:
            return CGSize(width: width, height: InfoRowCell.height)
        default:
            return CGSize(width: width, height: 10)
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        switch index {
        case 0:
            let cell = collectionContext?.dequeueReusableCell(of: TitleCollectionViewCell.self, for: self, at: index) as! TitleCollectionViewCell
            cell.setRedditPost(post: self.redditPost)
            return cell
        case 1:
            let cell = collectionContext?.dequeueReusableCell(of: PlayerCell.self, for: self, at: index) as! PlayerCell
            cell.setRedditPost(self.redditPost!)
            return cell
        case 2:
            let cell = collectionContext?.dequeueReusableCell(of: InfoRowCell.self, for: self, at: index) as! InfoRowCell
            cell.setRedditPost(post: self.redditPost)
            return cell
        default:
            return collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) as! UICollectionViewCell
        }
    }
    
    override func didUpdate(to object: Any) {
        if let post = object as? RedditPost {
            self.redditPost = post
        }
    }
    
    override func didSelectItem(at index: Int) {
        if index == 0 {
            self.redditPost.expandTitle = !self.redditPost.expandTitle
            self.updateCell(index: 0)
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
        if let controller = sectionController as? DisplaySectionController {
            // pre load player item
            controller.redditPost?.getPlayerItem().subscribe()
        }
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
    
    private func updateCell(index: Int) {
        collectionContext?.performBatch(animated: false, updates: { (batchContext) in
            batchContext.reload(in: self, at: IndexSet(integer: index))
        })
    }
}

