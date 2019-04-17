import IGListKit
import UIKit
import RxSwift

class YaikuCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {

    var data: [ListDiffable] = []
    let disposeBag = DisposeBag()
    var commentsTableView: CommentsTableView?
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 10)
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        if #available(iOS 10, *) {
            UICollectionView.appearance().isPrefetchingEnabled = false
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        self.adapter.collectionView = self.collectionView
        self.adapter.scrollViewDelegate = self
        self.adapter.dataSource = self
        self.fetchInitial()
        self.setupSubjectSubscriptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return RedditViewItemSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    @objc func fetchInitial(_ sender: Any? = nil) {
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {}

    func setupSubjectSubscriptions() {
        // show comments list
        Subjects.shared.showCommentsAction.subscribe(onNext: { redditViewItem in
            if self.isViewLoaded && self.view?.window != nil {
                self.commentsTableView?.dismiss()
                if let frame = MyNavigation.shared.rootViewController?.view.frame {
                    let totalNavItemHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + (self.tabBarController?.tabBar.frame.height ?? 0)
                    self.commentsTableView = CommentsTableView(frame: frame, redditViewItem: redditViewItem, totalNavItemHeight: totalNavItemHeight)
                    self.view.addSubview(self.commentsTableView!)
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
}
