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
    
    func setupSubjectSubscriptions() {
        Subjects.shared.moreButtonAction.subscribe(onNext: { redditViewItem in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let action1 = UIAlertAction(title: "Copy Video URL", style: .default) { (action:UIAlertAction) in
                UIPasteboard.general.string = redditViewItem.redditPost.url
            }
            
            let action2 = UIAlertAction(title: "Open in Reddit", style: .default) { (action:UIAlertAction) in
                guard let url = URL(string: "https://www.reddit.com\(redditViewItem.redditPost.permalink)") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            }
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
}
