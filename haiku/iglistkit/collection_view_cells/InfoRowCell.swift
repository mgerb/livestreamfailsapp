import Foundation
import UIKit
import SnapKit
import SwiftIcons
import RxSwift
import FlexLayout

class InfoRowCell: UICollectionViewCell {
    
    public static let height = CGFloat(50)
    var redditPost: RedditPost?
    let disposeBag = DisposeBag()

    lazy private var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy private var moreButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return button
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = false
        label.font = Config.smallFont
        label.textColor = Config.colors.primaryFont
        return label
    }()

    lazy private var rootViewContainer: UIView = {
        let view = UIView()
        view.flex.define{ flex in
            flex.addItem().justifyContent(.spaceBetween).direction(.row).padding(10).paddingBottom(0).define{ flex in
                
                flex.addItem().grow(1).direction(.row).define{ flex in
                    let l = UILabel()
                    l.font = Config.smallFont
                    l.text = "Score: "
                    l.textColor = Config.colors.primaryFont
                    flex.addItem(l)
                    flex.addItem(self.scoreLabel).grow(1)
                }
                
                flex.addItem().direction(.row).define{ flex in
                    flex.addItem(self.moreButton).marginVertical(-10)
                    flex.addItem(self.likeButton).marginVertical(-10)
                }
            }
        }
        return view
    }()
    
    func setRedditPost(post: RedditPost) {
        self.redditPost = post
        self.scoreLabel.text = post.score.commaRepresentation
        self.setupFlexLayout()
        self.setFavoriteButton()
        self.moreButton.setIcon(icon: .ionicons(.more), iconSize: 20, color: Config.colors.primaryFont, forState: .normal)
    }
    
    func setupFlexLayout() {
        self.rootViewContainer.removeFromSuperview()
        self.contentView.addSubview(self.rootViewContainer)
        self.rootViewContainer.pin.all()
        self.rootViewContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFlexLayout()

        Subjects.shared.favoriteButtonAction.subscribe(onNext: { p in
            if self.redditPost?.id == p.id {
                self.redditPost?.favorited = p.favorited
                self.setFavoriteButton()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func setFavoriteButton() {
        let color = self.redditPost?.favorited == true ? Config.colors.red : Config.colors.primaryFont
        let icon = self.redditPost?.favorited == true ? FontType.ionicons(.iosHeart) : FontType.ionicons(.iosHeartOutline)
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
        if let p = self.redditPost {
            if p.favorited {
                p.favorited = false
                StorageService.shared.deleteRedditPostFavorite(id: p.id)
            } else {
                p.favorited = true
                StorageService.shared.storeRedditPostFavorite(redditPost: p)
            }
            self.animateFavoriteButton()
            Subjects.shared.favoriteButtonAction.onNext(p)
        }
        Util.hapticFeedbackSuccess()
    }
    
    @objc func moreButtonAction() {
        Subjects.shared.moreButtonAction.onNext(self.redditPost!)
    }
    
}
