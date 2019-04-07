//
//  LabelCell.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/24/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import AVKit;
import AVFoundation;
import Kingfisher
import RxSwift
import SwiftIcons

class PlayerCell: UICollectionViewCell {
    
    public var redditViewItem: RedditViewItem?
    private var thumbnail = UIImageView()
    
    // used to unsubscribe when component deinits
    let disposeBag = DisposeBag()
    
    // used to unsubscribe when reddit post will change
    var progressSubscription: Disposable?

    lazy private var fullScreenButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 4
        view.alpha = 0

        return view
    }()
    
    lazy private var fullScreenButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(fullScreenButtonAction), for: .touchUpInside)
        button.setIcon(icon: .googleMaterialDesign(.fullscreen), iconSize: 25, color: Config.colors.white, forState: .normal)
        return button
    }()
    
    lazy private var progressBar: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy private var playerView: MyPlayerView = {
        let view = MyPlayerView()
        view.alpha = 0
        return view
    }()
    
    lazy private var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        
        // add subviews
        self.addSubview(self.playerView)
        self.playerView.sendSubview(toBack: self.bgView)
        self.addSubview(self.fullScreenButtonContainer)
        self.fullScreenButtonContainer.addSubview(self.fullScreenButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setGlobalPlayerItemSubscription()

        // player view
        self.playerView.pin.all()

        // full screen button
        self.fullScreenButtonContainer.pin.right().bottom().height(25).width(30).marginRight(5).marginBottom(5)
        self.fullScreenButton.pin.all()
    }
    
    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.setRedditViewItemSubscriptions()
        
        DispatchQueue.main.async {
            self.setThumbnail(self.redditViewItem!.thumbnail)
            if GlobalPlayer.shared.isActivePlayerItem(item: self.redditViewItem!) {
                self.showPlayerView()
            } else {
                self.showThumbnail(true)
            }
        }
    }
    
    private func setThumbnail(_ view: UIImageView) {
        DispatchQueue.main.async {
            self.thumbnail = view
            self.addSubview(self.thumbnail)
            self.thumbnail.pinFrame.all()
            self.bringSubview(toFront: self.playerView)
            self.bringSubview(toFront: self.fullScreenButtonContainer)
        }
    }

     func setRedditViewItemSubscriptions() {
//         self.progressSubscription = self.redditViewItem!.playerProgress.subscribe(onNext: { p in
//            self.updateProgressBarConstraints(p)
//         })
     }
    
    func setGlobalPlayerItemSubscription() {
        GlobalPlayer.shared.activeRedditViewItem.subscribe(onNext: { item in
            if self.redditViewItem === item {
                self.showPlayerView()
            } else {
                self.showThumbnail(true)
            }
        }).disposed(by: self.disposeBag)
    }
    
//    func updateProgressBarConstraints(_ progress: Double?) {
//        self.progressBar.snp.remakeConstraints{ make in
//            make.bottom.equalTo(self).offset(2)
//            make.left.equalTo(self)
//            make.height.equalTo(2)
//            if progress != nil && progress! > 0 {
//                make.width.equalTo(self).multipliedBy(progress!)
//            }
//        }
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
            self.thumbnail.removeFromSuperview()
            self.progressSubscription?.dispose()
            self.redditViewItem = nil
        }
    
    @objc func fullScreenButtonAction() {
        GlobalPlayer.shared.pause()
        MyNavigation.shared.presentVideoPlayer(redditViewItem: self.redditViewItem!)
    }
    
    @objc func onTap() {
        DispatchQueue.main.async {
            _ = self.redditViewItem!.updateGlobalPlayer().subscribe()
            self.toggleFullScreenButton()
        }
    }
    
    var fullScreenTimeoutTask: DispatchWorkItem?
    
    /// hide the full screen button after 3 seconds
    func toggleFullScreenButton() {
        self.fullScreenTimeoutTask?.cancel()
        self.fullScreenTimeoutTask = DispatchWorkItem {
            self.animateView(view: self.fullScreenButtonContainer, alpha: 0)
        }
        self.animateView(view: self.fullScreenButtonContainer, alpha: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: self.fullScreenTimeoutTask!)
    }
    
    func showThumbnail(_ animated: Bool) {
        // no need to do animation if already hidden
        if self.playerView.alpha == 0 && self.fullScreenButtonContainer.alpha == 0 {
            return
        }
        
        self.playerView.playerLayer.player = nil
        
        if animated {
            self.animateView(view: self.playerView, alpha: 0)
            self.animateView(view: self.fullScreenButtonContainer, alpha: 0)
        } else {
            self.playerView.alpha = 0
            self.fullScreenButtonContainer.alpha = 0
        }
    }
    
    func showPlayerView() {
        self.playerView.playerLayer.player = GlobalPlayer.shared.player
        self.playerView.playerLayer.setNeedsDisplay()
        self.animateView(view: self.playerView, alpha: 1)
    }
    
    func animateView(view: UIView, alpha: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = alpha
        })
    }
}
