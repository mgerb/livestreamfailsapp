import Foundation
import UIKit
import SnapKit
import SwiftIcons
import RxSwift
import FlexLayout

class InfoRowCell: UICollectionViewCell {
    
    public static let height = CGFloat(40)
    var redditViewItem: RedditViewItem?
    let disposeBag = DisposeBag()
    let rxUnsubscribe = PublishSubject<Void>()

    lazy private var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy private var moreButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        button.setIcon(icon: .ionicons(.more), iconSize: 20, color: Config.colors.primaryFont, forState: .normal)
        return button
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = false
        label.font = Config.smallFont
        label.textColor = Config.colors.primaryFont
        return label
    }()
    
    lazy private var commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(Config.colors.primaryFont, for: .normal)
        button.titleLabel?.font = Config.smallFont
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy private var commentBubble: UIButton = {
        let button = UIButton()
        button.setIcon(icon: .fontAwesomeRegular(.comment), iconSize: 20, color: Config.colors.primaryFont, backgroundColor: UIColor.black.withAlphaComponent(0), forState: .normal)
        return button
    }()

    lazy private var rootViewContainer: UIView = {
        let view = UIView()
        view.flex.define{ flex in
            flex.addItem().justifyContent(.spaceBetween).direction(.row).padding(10).paddingBottom(0).paddingTop(5).define{ flex in
                
                flex.addItem().direction(.row).define{ flex in
                    let l = UILabel()
                    l.font = Config.smallFont
                    l.setIcon(icon: .googleMaterialDesign(.arrowUpward), iconSize: 20)
                    l.textColor = Config.colors.primaryFont
                    
                    flex.addItem(l)
                    flex.addItem(self.scoreLabel)
                    flex.addItem(self.commentBubble).marginLeft(10)
                    flex.addItem(self.commentsButton)
                }
                
                flex.addItem().direction(.row).define{ flex in
                    flex.addItem(self.moreButton).marginVertical(-10)
                    flex.addItem(self.likeButton).marginVertical(-10)
                }
            }
        }
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.rootViewContainer)
        self.rootViewContainer.pin.all()
        self.rootViewContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rxUnsubscribe.onNext(())
    }
    
    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.scoreLabel.text = item.redditPost.score.commaRepresentation
        self.scoreLabel.flex.markDirty()
        self.commentsButton.setTitle(String(item.redditPost.num_comments), for: .normal)
        self.commentsButton.flex.markDirty()
        self.commentBubble.flex.markDirty()
        self.rootViewContainer.flex.layout(mode: .adjustHeight)
        _ = self.redditViewItem?.favorited.takeUntil(self.rxUnsubscribe).subscribe(onNext: { favorited in
            self.setFavoriteButton(favorited)
        })
    }

    private func setFavoriteButton(_ favorited: Bool) {
        let color = favorited == true ? Config.colors.red : Config.colors.primaryFont
        let icon = favorited == true ? FontType.ionicons(.iosHeart) : FontType.ionicons(.iosHeartOutline)
        self.likeButton.setIcon(icon: icon, iconSize: 30, color: color, forState: .normal)
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
    
}
