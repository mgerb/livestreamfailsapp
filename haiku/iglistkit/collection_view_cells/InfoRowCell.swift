import Foundation
import UIKit
import SnapKit
import SwiftIcons

class InfoRowCell: UICollectionViewCell {
    
    public static let height = CGFloat(50)
    var redditPost: RedditPost? {
        didSet {
        }
    }

    lazy private var likeButton: UIButton = {
        let button = UIButton()
        self.contentView.addSubview(button)
        button.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
        button.setIcon(icon: .fontAwesomeSolid(.heart), iconSize: 30, color: Config.colors.primaryLight, forState: .normal)
        return button
    }()
    
    func setRedditPost(post: RedditPost) {
        self.redditPost = post
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.likeButton.snp.makeConstraints{ make in
            make.right.equalTo(self).offset(-15)
            make.centerY.equalTo(self)
        }
    }
    
    @objc func likeButtonAction() {
        // do popping animation on button and update color
        // TODO: see if possible to animate button color change
        let duration = 0.15
        UIView.animate(withDuration: duration,
           animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.likeButton.setIcon(icon: .fontAwesomeSolid(.heart), iconSize: 30, color: Config.colors.red, forState: .normal)
        },
           completion: { _ in
            UIView.animate(withDuration: duration) {
                self.likeButton.transform = CGAffineTransform.identity
            }
        })
        Util.hapticFeedbackSuccess()
    }
    
}
