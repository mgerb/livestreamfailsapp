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
    
    lazy public var playerView: MyPlayerView = {
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
    
    private var playerItem: AVPlayerItem?
    var thumbnail = UIImageView()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(self.thumbnail)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.contentView.addGestureRecognizer(tap)
        self.setGlobalPlayerItemSubscription()
    }
    
    let disposeBag = DisposeBag()
    func setGlobalPlayerItemSubscription() {
        GlobalPlayer.shared.playerItemSubject
            .subscribe(onNext: {item in
                self.playerItem === item ? self.showPlayerView() : self.showThumbnail()
            }).disposed(by: self.disposeBag)
    }

    func setPlayerItem(_ item: AVPlayerItem?) {
        self.playerItem = item
        if item != nil && item === GlobalPlayer.shared.player.currentItem {
            self.playerView.playerLayer.player = GlobalPlayer.shared.player
            self.showPlayerView()
        } else {
            self.playerView.playerLayer.player = nil
            self.showThumbnail()
        }
    }
    
    func setThumbnail(_ view: UIImageView) {
        self.thumbnail = view
        self.contentView.addSubview(self.thumbnail)
        self.thumbnail.snp.makeConstraints{make in
            make.edges.equalTo(self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.contentView.contains(self.thumbnail) {
            self.thumbnail.removeFromSuperview()
            self.playerItem = nil
        }
    }
    
    @objc func onTap() {
        if self.playerItem == nil {
            return
        }
        if self.playerItem !== GlobalPlayer.shared.player.currentItem {
            GlobalPlayer.shared.replaceItem(self.playerItem!)
            self.playerView.playerLayer.player = GlobalPlayer.shared.player
        } else {
            GlobalPlayer.shared.togglePlaying()
        }
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
