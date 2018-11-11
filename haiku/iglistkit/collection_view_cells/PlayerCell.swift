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
    let unsubscribeRedditPost = PublishSubject<Void>()

    lazy private var playerView: MyPlayerView = {
        let view = MyPlayerView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints{make in
            make.edges.equalTo(self)
        }
        view.alpha = 0
        let bgView = UIView()
        bgView.backgroundColor = .black
        view.addSubview(bgView)
        view.sendSubview(toBack: bgView)
        bgView.snp.makeConstraints{make in
            make.edges.equalTo(self)
        }
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.thumbnail)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.contentView.addGestureRecognizer(tap)
        self.setGlobalPlayerItemSubscription()
    }
    
    func setRedditViewItem(item: RedditViewItem) {
        self.redditViewItem = item
        self.setThumbnail(self.redditViewItem!.thumbnail)
        do {
            if GlobalPlayer.shared.isItemPlaying(item: self.redditViewItem!) {
                self.showPlayerView()
                self.playerView.player = GlobalPlayer.shared.player
            } else {
                self.showThumbnail()
                self.playerView.player = nil
            }
        } catch {
            self.showThumbnail()
            self.playerView.player = nil
        }
    }
    
    private func setThumbnail(_ view: UIImageView) {
        self.thumbnail = view
        self.contentView.addSubview(self.thumbnail)
        self.thumbnail.snp.makeConstraints{make in
            make.edges.equalTo(self)
        }
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
            self.unsubscribeRedditPost.onNext(())
            self.redditViewItem = nil
        }
    }
    
    @objc func onTap() {
        _ = self.redditViewItem?.playerItemObservable
            .takeUntil(self.unsubscribeRedditPost)
            .subscribe(onNext: { item in
            GlobalPlayer.shared.replaceItem(item!, self.redditViewItem!)
        })
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
