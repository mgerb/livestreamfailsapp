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
        return 2
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        if index == 0 {
            return CGSize(width: width, height: 30)
        } else if index == 1 {
            let height = (width * 9 / 16)
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: 10)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if index == 0 {
            guard let cell = collectionContext?.dequeueReusableCell(of: TitleCollectionViewCell.self, for: self, at: index) as? TitleCollectionViewCell else {
                fatalError()
            }
            cell.text = redditPost.title
            return cell
        } else if index == 1 {
            guard let cell = collectionContext?.dequeueReusableCell(of: PlayerCell.self, for: self, at: index) as? PlayerCell else {
                fatalError()
            }
            
            cell.setThumbnail(self.redditPost!.thumbnail)
            
            self.redditPost!.getPlayerItem().subscribe(onNext: { item in
                cell.setPlayerItem(self.redditPost!.playerItem)
            })

            return cell
        }
        
        return collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) as! UICollectionViewCell
    }
    
    override func didUpdate(to object: Any) {
        if let post = object as? RedditPost {
            self.redditPost = post
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
        if let controller = sectionController as? DisplaySectionController {
            // pre load player item
            controller.redditPost!.getPlayerItem().subscribe{}
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
}

