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
    
    private var redditViewItem: RedditViewItem?
    private var thumbnail = UIImageView()
    // used to unsubscribe when component deinits
    let disposeBag = DisposeBag()
    // used to unsubscribe when reddit post will change
    var progressSubscription: Disposable?

    lazy private var fullScreenButtonContainer: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.right.equalTo(self.contentView).inset(5)
            make.bottom.equalTo(self.contentView).inset(5)
            make.height.equalTo(25)
        }
        view.backgroundColor = .black
        view.layer.cornerRadius = 4
        view.alpha = 0

        // button
        let button = UIButton()
        view.addSubview(button)
        button.addTarget(self, action: #selector(fullScreenButtonAction), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        button.setIcon(icon: .googleMaterialDesign(.fullscreen), iconSize: 25, color: Config.colors.white, forState: .normal)
        return view
    }()
    
    lazy private var progressBar: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.backgroundColor = .red
        return view
    }()
    
    lazy private var playerView: MyPlayerView = {
        let view = MyPlayerView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints{make in
            make.edges.equalTo(self.contentView)
        }
        view.alpha = 0
        let bgView = UIView()
        bgView.backgroundColor = .black
        view.addSubview(bgView)
        view.sendSubview(toBack: bgView)
        bgView.snp.makeConstraints{make in
            make.edges.equalTo(self.contentView)
        }
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.contentView.addGestureRecognizer(tap)
        self.setGlobalPlayerItemSubscription()
    }
    
    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.setThumbnail(self.redditViewItem!.thumbnail)
        self.setRedditViewItemSubscriptions()
        if GlobalPlayer.shared.isActivePlayerItem(item: self.redditViewItem!) {
            self.showPlayerView()
            self.playerView.player = GlobalPlayer.shared.player
        } else {
            self.showThumbnail()
            self.playerView.player = nil
        }
    }
    
    private func setThumbnail(_ view: UIImageView) {
        self.thumbnail = view
        self.contentView.addSubview(self.thumbnail)
        self.thumbnail.snp.makeConstraints{make in
            make.edges.equalTo(self.contentView)
        }
    }

     func setRedditViewItemSubscriptions() {
         self.progressSubscription = self.redditViewItem!.playerProgress.subscribe(onNext: { p in
            self.updateProgressBarConstraints(p)
         })
     }
    
    func setGlobalPlayerItemSubscription() {
        GlobalPlayer.shared.activeRedditViewItem.subscribe(onNext: { item in
            if self.redditViewItem! === item {
                self.showPlayerView()
                self.playerView.playerLayer.player = GlobalPlayer.shared.player
            } else {
                self.showThumbnail()
            }
        }).disposed(by: self.disposeBag)
    }
    
    func updateProgressBarConstraints(_ progress: Double?) {
        self.progressBar.snp.remakeConstraints{ make in
            make.bottom.equalTo(self.contentView).offset(2)
            make.left.equalTo(self.contentView)
            make.height.equalTo(2)
            if progress != nil && progress! > 0 {
                make.width.equalTo(self.contentView).multipliedBy(progress!)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if self.contentView.contains(self.thumbnail) {
            self.thumbnail.removeFromSuperview()
            self.progressSubscription?.dispose()
            self.redditViewItem = nil
        }
    }
    
    @objc func fullScreenButtonAction() {
        GlobalPlayer.shared.pause()
        MyNavigation.shared.presentVideoPlayer(redditViewItem: self.redditViewItem!)
    }
    
    @objc func onTap() {
        DispatchQueue.main.async {
            self.redditViewItem!.updateGlobalPlayer()
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
    
    func showThumbnail() {
        self.animateView(view: self.thumbnail, alpha: 1)
        self.animateView(view: self.playerView, alpha: 0)
        self.animateView(view: self.fullScreenButtonContainer, alpha: 0)
    }
    
    func showPlayerView() {
        self.animateView(view: self.thumbnail, alpha: 0)
        self.animateView(view: self.playerView, alpha: 1)
    }
    
    func animateView(view: UIView, alpha: CGFloat) {
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = alpha
        })
    }
}
