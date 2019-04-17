import IGListKit
import UIKit
import RxSwift
import RevealingSplashView

class MainCollectionViewController: YaikuCollectionViewController, SortBarDelegate {

    private var readyToLoadMore = true
    private var loadMoreTimeoutWorkItem: DispatchWorkItem?
    private var redditPostSortBy = RedditPostSortBy.hot
    private var redditPostSortByTop = RedditPostSortByTop.week
    private let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "app_icon.png")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:1, green:1, blue:1, alpha:1.0))
    private let refreshControl = UIRefreshControl()
    private var didShowAnimation = false
    
    override func viewDidLoad() {
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(fetchInitial(_:)), for: .valueChanged)
        
        super.viewDidLoad()
        self.navigationItem.title = "Live Stream Fails"
        self.collectionView.contentOffset.y = SortBarCollectionViewCell.height
    }
    
    override func viewWillLayoutSubviews() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.addSubview(self.revealingSplashView)
        }
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
        if after == nil {
            if !self.refreshControl.isRefreshing {
                self.refreshControl.beginRefreshing()
            }
        }

        // cancel load more timeout if we reload the data completely
        if after == nil {
            self.loadMoreTimeoutWorkItem?.cancel()
            GlobalPlayer.shared.pause()
        }

        RedditService.shared.getHaikus(after: after, sortBy: self.redditPostSortBy, sortByTop: self.redditPostSortByTop){ redditPosts in
            let redditViewItems: [RedditViewItem] = redditPosts.compactMap {
                let item = RedditViewItem($0, context: .home)
                // filter out items with bad url's
                // TODO: filter out reddit posts with bad url's
                return item
            }
            
            DispatchQueue.main.async {
            
                let sortBar = ["sort bar"] as [ListDiffable]
                if after == nil {
                    self.data = sortBar + redditViewItems
                } else {
                    self.data = self.data + redditViewItems
                }

                self.refreshControl.endRefreshing()
                
                // start twitter like animation
                if !self.didShowAnimation {
                    self.revealingSplashView.startAnimation() {
                        self.didShowAnimation = true
                    }
                }

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
        
        // show alert controller
        if self.redditPostSortBy == .top {
            let controller = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
            
            RedditPostSortByTop.allCases.forEach { val in
                let action = UIAlertAction(title: val.rawValue, style: .default, handler: { _ in
                    self.redditPostSortByTop = val
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
                    self.fetchHaikus()
                })
                controller.addAction(action)
            }
            
            controller.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
        } else {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
            self.fetchHaikus()
        }

    }
    
    func activeRedditPostSortBy() -> RedditPostSortBy {
        return self.redditPostSortBy
    }
}
