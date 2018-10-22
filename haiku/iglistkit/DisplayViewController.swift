import IGListKit
import UIKit
import RxSwift

class DisplayViewController: YaikuCollectionViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.refreshControl.isRefreshing {
            if let redditPost = self.data[self.data.count - 1] as? RedditPost {
                self.refreshControl.beginRefreshing()
                self.fetchHaikus(redditPost.name)
            }
        }
    }

    override func fetchHaikus(_ after: String? = nil) {
        RedditService.shared.getHaikus(after: after){ redditPosts in
            self.data = after == nil ? redditPosts : self.data + redditPosts
            self.adapter.performUpdates(animated: true, completion: { _ in
                self.refreshControl.endRefreshing()
            })
        }
    }
}
