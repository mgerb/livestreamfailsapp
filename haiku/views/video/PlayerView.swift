//
//  PlayerCellView.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/28/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class PlayerView: UIView, VideoView {
    
    lazy private var myPlayerView: MyPlayerView = {
        let view = MyPlayerView()
        view.alpha = 0
        return view
    }()
    
    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.myPlayerView)
        self.addSubview(self.thumbnail)
        
        self.myPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.thumbnail.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var subscription: Disposable?
    
    func setRedditItem(redditViewItem: RedditViewItem) {
        self.thumbnail.image = nil
        self.subscription?.dispose()
        self.subscription = redditViewItem.getThumbnailImage.subscribe(onNext: { image, animate in
            self.thumbnail.image = image
        })
    }
}
