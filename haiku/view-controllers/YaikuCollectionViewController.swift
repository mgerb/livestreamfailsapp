import IGListKit
import UIKit
import RxSwift

class YaikuCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var data: [RedditViewItem] = []
    let refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DisplaySectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
    @objc func fetchInitial(_ sender: Any? = nil) {
        if !self.refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
        self.fetchHaikus()
    }
    
    func fetchHaikus(_ after: String? = nil) {}
}
