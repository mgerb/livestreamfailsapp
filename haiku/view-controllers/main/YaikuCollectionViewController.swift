import IGListKit
import UIKit
import RxSwift

class YaikuCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var data: [ListDiffable] = []
    let refreshControl = UIRefreshControl()
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
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(fetchInitial(_:)), for: .valueChanged)
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
        if let _ = object as? RedditViewItem {
            return RedditViewItemSectionController()
        } else {
            return SortBarSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    @objc func fetchInitial(_ sender: Any? = nil) {
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {
        if after == nil {
            GlobalPlayer.shared.pause()
            if !self.refreshControl.isRefreshing {
                self.refreshControl.beginRefreshing()
            }
        }
    }

    func setupSubjectSubscriptions() {
        // show comments list
        Subjects.shared.showCommentsAction.subscribe(onNext: { redditViewItem in
            if self.isViewLoaded && self.view?.window != nil {
                self.commentsTableView?.dismiss()
                self.commentsTableView = CommentsTableView(frame: self.view.frame, redditViewItem: redditViewItem)
                self.view.addSubview(self.commentsTableView!)
            }
        }).disposed(by: self.disposeBag)
        
        Subjects.shared.sortButtonAction.subscribe(onNext: {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
            self.fetchHaikus()
        }).disposed(by: self.disposeBag)
    }
}
