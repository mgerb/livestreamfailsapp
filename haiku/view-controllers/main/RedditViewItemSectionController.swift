import IGListKit
import UIKit
import AVKit

final class RedditViewItemSectionController: ListSectionController, ListDisplayDelegate, ListWorkingRangeDelegate {


    public var redditViewItem: RedditViewItem!

    override init() {
        super.init()
        displayDelegate = self
        workingRangeDelegate = self
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 3
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        switch index {
        case 0:
            return CGSize(width: width, height: self.getTitleCellHeight(width))
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
            let cell = collectionContext!.dequeueReusableCell(of: TitleCollectionViewCell.self, for: self, at: index) as! TitleCollectionViewCell
            return cell
        case 1:
            let cell = collectionContext!.dequeueReusableCell(of: PlayerCell.self, for: self, at: index) as! PlayerCell
            return cell
        case 2:
            let cell = collectionContext!.dequeueReusableCell(of: InfoRowCell.self, for: self, at: index) as! InfoRowCell
            return cell
        default:
            return collectionContext!.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index)
        }
    }
    
    override func didUpdate(to object: Any) {
        if let item = object as? RedditViewItem {
            self.redditViewItem = item
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
        // TODO: maybe change this back?
    //    if let controller = sectionController as? RedditViewItemSectionController {
    //         // pre load player item
    //        controller.redditViewItem?.getPlayerItem().subscribe()
    //    }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if index >= 0 || index <= 2 {
            if let cell = cell as? TitleCollectionViewCell {
                cell.setRedditViewItem(item: self.redditViewItem)
            }

            if let cell = cell as? InfoRowCell {
                cell.setRedditViewItem(item: self.redditViewItem)
            }

            if let cell = cell as? PlayerCell {
                cell.setRedditViewItem(item: self.redditViewItem)
            }
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
    
    private func updateCell(index: Int) {
        collectionContext?.performBatch(animated: false, updates: { (batchContext) in
            batchContext.reload(in: self, at: IndexSet(integer: index))
        })
    }
    
    private func getTitleCellHeight(_ width: CGFloat) -> CGFloat {
        // width of everything else except the title
        let cellOffsetWidth = TitleCollectionViewCell.padding * 2
        return self.redditViewItem.redditPost.title.heightWithConstrainedWidth(width: width - cellOffsetWidth, font: Config.defaultFont) + 20
    }
}

