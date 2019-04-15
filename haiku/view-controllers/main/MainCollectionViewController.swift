import IGListKit
import UIKit
import RxSwift

class MainCollectionViewController: YaikuCollectionViewController, SortBarDelegate {

    private var readyToLoadMore = true
    private var loadMoreTimeoutWorkItem: DispatchWorkItem?
    private var redditPostSortBy = RedditPostSortBy.hot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentOffset.y = SortBarCollectionViewCell.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing && self.readyToLoadMore && self.data.count > 0 {
            if let redditViewItem = self.data[self.data.count - 1] as? RedditViewItem {
                self.readyToLoadMore = false
                self.fetchHaikus(redditViewItem.redditPost.name)
            }
        }
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let _ = object as? RedditViewItem {
            return RedditViewItemSectionController()
        } else {
            let controller = SortBarSectionController()
            controller.delegate = self
            return controller
        }
    }

    override func fetchHaikus(_ after: String? = nil) {
        super.fetchHaikus()
        
        // cancel load more timeout if we reload the data completely
        if after == nil {
            self.loadMoreTimeoutWorkItem?.cancel()
            GlobalPlayer.shared.pause()
        }

        RedditService.shared.getHaikus(after: after, sortBy: self.redditPostSortBy){ redditPosts in
            let redditViewItems: [RedditViewItem] = redditPosts.compactMap {
                let item = RedditViewItem($0, context: .home)
                // filter out items with bad url's
                // TODO: filter out reddit posts with bad url's
                return item
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                let sortBar = ["sort bar"] as [ListDiffable]
                if after == nil {
                    self.data = sortBar + redditViewItems
                } else {
                    self.data = self.data + redditViewItems
                }

                self.refreshControl.endRefreshing()

                if after == nil {
                    self.adapter.reloadData(completion: nil)
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: SortBarCollectionViewCell.height), animated: true)
                    self.readyToLoadMore = true
                } else {
                    self.adapter.performUpdates(animated: true, completion: { _ in
                        self.loadMoreTimeoutWorkItem = DispatchWorkItem {
                            self.readyToLoadMore = true
                        }
                        // if we don't return any reddit items wait at least 10 seconds before trying again
                        if redditViewItems.count == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: self.loadMoreTimeoutWorkItem!)
                        } else {
                            self.readyToLoadMore = true
                        }
                    })
                }
                    
            }
        }
    }

    func sortBarDidUpdate(sortBy: RedditPostSortBy) {
        self.redditPostSortBy = sortBy
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
        self.fetchHaikus()
    }
    
    func activeRedditPostSortBy() -> RedditPostSortBy {
        return self.redditPostSortBy
    }
}
