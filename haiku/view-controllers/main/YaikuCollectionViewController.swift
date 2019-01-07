import IGListKit
import UIKit
import RxSwift

class YaikuCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var data: [RedditViewItem] = []
    let refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    var commentsCollectionView: CommentsCollectionView?
    
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
        return RedditViewItemSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    @objc func fetchInitial(_ sender: Any? = nil) {
        if !self.refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {}

    func setupSubjectSubscriptions() {
        // show comments list
        Subjects.shared.showCommentsAction.subscribe(onNext: { redditViewItem in
            if self.isViewLoaded && self.view?.window != nil {
                self.commentsCollectionView?.dismiss()
                self.commentsCollectionView = CommentsCollectionView.getInstance(self, redditViewItem)
                self.view.addSubview(self.commentsCollectionView!)
                self.commentsCollectionView!.frame = self.view.frame
            }
        }).disposed(by: self.disposeBag)
    }
}