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

class PlayerCell: UICollectionViewCell {
    
    private var redditViewItem: RedditViewItem?
    private var thumbnail = UIImageView()
    // used to unsubscribe when component deinits
    let disposeBag = DisposeBag()
    // used to unsubscribe when reddit post will change
    let rxUnsubscribe = PublishSubject<Void>()

    lazy private var progressBar: UIView = {
        let view = UIView()
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
        self.contentView.addSubview(self.progressBar)
        self.progressBar.snp.makeConstraints{ make in
            make.bottom.equalTo(self.contentView).offset(2)
            make.left.equalTo(self.contentView)
            make.height.equalTo(2)
            make.width.equalTo(0)
        }
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
         _ = self.redditViewItem!.playerProgress.takeUntil(self.rxUnsubscribe).subscribe(onNext: { p in
            if p > 0 {
               self.progressBar.snp.makeConstraints{ make in
                   make.width.equalTo(self.contentView).multipliedBy(p)
               }
            }
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

    override func prepareForReuse() {
        super.prepareForReuse()
        if self.contentView.contains(self.thumbnail) {
            self.thumbnail.removeFromSuperview()
            self.rxUnsubscribe.onNext(())
            self.redditViewItem = nil
        }
    }
    
    @objc func onTap() {
        self.redditViewItem?.updateGlobalPlayer()
    }
    
    func showThumbnail() {
        self.animateView(view: self.thumbnail, alpha: 1)
        self.animateView(view: self.playerView, alpha: 0)
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
