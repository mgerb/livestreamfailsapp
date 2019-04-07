import Foundation
import UIKit
import SnapKit
import RxSwift
import FlexLayout

class InfoRowCell: UICollectionViewCell {
    
    public static let height = CGFloat(40)
    var redditViewItem: RedditViewItem?
    let disposeBag = DisposeBag()
    let rxUnsubscribe = PublishSubject<Void>()

    lazy private var likeButton: UILabel = {
        return Icons.getLabel(icon: .heart, target: self, action: #selector(likeButtonAction))
    }()
    
    lazy private var moreButton: UILabel = {
        return Icons.getLabel(icon: .dots, target: self, action: #selector(moreButtonAction))
    }()
    
    let scoreLabel: UILabel = {
        let label = Labels.new(font: .small)
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let timeStampLabel: UILabel = {
        return Labels.new(font: .small, color: .secondary)
    }()
    
    lazy private var commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(Config.colors.primaryFont, for: .normal)
        button.titleLabel?.font = Config.smallFont
        // set to nearly zero for left/right as 0 makes it use default values...
        button.contentEdgeInsets = UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1)
        button.addTarget(self, action: #selector(commentsButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy private var commentBubble: UILabel = {
        return Icons.getLabel(icon: .comment, target: self, action: #selector(commentsButtonAction))
    }()

    lazy private var rootViewContainer: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.flex.define{ flex in
            flex.addItem().justifyContent(.spaceBetween).direction(.row).padding(10).paddingBottom(0).paddingTop(10).define{ flex in
                
                flex.addItem().direction(.row).define{ flex in
                    let l = Icons.getLabel(icon: .arrowUp)
                    
                    flex.addItem().direction(.row).define { flex in
                        flex.addItem(l)
                        flex.addItem(self.scoreLabel)
                    }
                    flex.addItem().direction(.row).marginLeft(10).define { flex  in
                        flex.addItem(self.commentBubble).marginRight(5)
                        flex.addItem(self.commentsButton)
                    }
                    flex.addItem(self.timeStampLabel).marginLeft(10)
                }
                
                flex.addItem().direction(.row).define{ flex in
                    flex.addItem(self.moreButton).marginVertical(-10).marginRight(5)
                    flex.addItem(self.likeButton).marginVertical(-10)
                }
            }
        }
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rootViewContainer.pin.all()
        self.rootViewContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rxUnsubscribe.onNext(())
    }
    
    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        _ = self.redditViewItem?.favorited.takeUntil(self.rxUnsubscribe.asObservable()).subscribe(onNext: { favorited in
            self.setFavoriteButton(favorited)
        })
        
        DispatchQueue.main.async {
            self.scoreLabel.text = item.redditPost.score.commaRepresentation
            self.scoreLabel.flex.markDirty()
            self.commentsButton.setTitle(String(item.redditPost.num_comments), for: .normal)
            self.commentsButton.flex.markDirty()
            self.commentBubble.flex.markDirty()
            self.timeStampLabel.text = item.humanTimeStampExtended
            self.timeStampLabel.flex.markDirty()
            self.rootViewContainer.flex.layout()
        }
    }

    private func setFavoriteButton(_ favorited: Bool) {
        let color = favorited == true ? Config.colors.red : Config.colors.primaryFont
        let icon = favorited == true ? MyIconType.heartFill : MyIconType.heart
        self.likeButton.updateIcon(icon: icon, color: color)
    }
    
    private func animateFavoriteButton() {
        // do popping animation on button and update color
        // TODO: see if possible to animate button color change
        let duration = 0.10
        UIView.animate(withDuration: duration,
           animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        },
           completion: { _ in
            UIView.animate(withDuration: duration) {
                self.likeButton.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc func likeButtonAction() {
        self.animateFavoriteButton()
        self.redditViewItem?.toggleFavorite()
    }
    
    @objc func moreButtonAction() {
        Subjects.shared.moreButtonAction.onNext(self.redditViewItem!)
    }
    
    @objc func commentsButtonAction() {
        Subjects.shared.showCommentsAction.onNext(self.redditViewItem!)
    }
    
}
