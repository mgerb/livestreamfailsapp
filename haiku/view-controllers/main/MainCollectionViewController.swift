import IGListKit
import UIKit
import RxSwift

class MainCollectionViewController: YaikuCollectionViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing {
            if self.data.count > 0 {
                if let redditViewItem = self.data[self.data.count - 1] as RedditViewItem? {
                    self.refreshControl.beginRefreshing()
                    self.fetchHaikus(redditViewItem.redditPost.name)
                }
            }
        }
    }

    override func fetchHaikus(_ after: String? = nil) {
        RedditService.shared.getHaikus(after: after){ redditPosts in
            let redditViewItems: [RedditViewItem] = redditPosts.compactMap {
                let item = RedditViewItem($0, context: .home)
                // filter out items with bad url's
                // TODO: filter out reddit posts with bad url's
                return item
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.data = after == nil ? redditViewItems : self.data + redditViewItems
                self.adapter.performUpdates(animated: true, completion: { _ in
                    self.refreshControl.endRefreshing()
                })
            }
        }
    }
}
