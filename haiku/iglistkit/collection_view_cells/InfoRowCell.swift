import Foundation
import UIKit
import SnapKit
import SwiftIcons

class InfoRowCell: UICollectionViewCell {
    
    public static let height = CGFloat(50)
    var redditPost: RedditPost?

    lazy private var likeButton: UIButton = {
        let button = UIButton()
        self.contentView.addSubview(button)
        button.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
        return button
    }()
    
    func setRedditPost(post: RedditPost) {
        self.redditPost = post
        self.setFavoriteButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.likeButton.snp.makeConstraints{ make in
            make.right.equalTo(self).offset(-15)
            make.centerY.equalTo(self)
        }
    }
    
    private func setFavoriteButton() {
        let color = self.redditPost?.favorited == true ? Config.colors.red : Config.colors.primaryLight
        self.likeButton.setIcon(icon: .fontAwesomeSolid(.heart), iconSize: 30, color: color, forState: .normal)
    }
    
    private func animateFavoriteButton() {
        // do popping animation on button and update color
        // TODO: see if possible to animate button color change
        let duration = 0.15
        UIView.animate(withDuration: duration,
           animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.setFavoriteButton()
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
        }
        Util.hapticFeedbackSuccess()
    }
    
}
