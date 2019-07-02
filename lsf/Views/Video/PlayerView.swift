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
import SwiftIcons

class PlayerView: UIView {
    
    var redditViewItem: RedditViewItem?
    
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
        
        self.setGlobalPlayerItemSubscription()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)

        self.addSubview(self.thumbnail)
        self.addSubview(self.myPlayerView)
        self.addSubview(self.fullScreenButtonContainer)
        self.fullScreenButtonContainer.addSubview(self.fullScreenButton)

        self.thumbnail.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.myPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.fullScreenButtonContainer.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().offset(-5)
            make.height.equalTo(25)
            make.width.equalTo(30)
        }
        
        self.fullScreenButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var subscription: Disposable?
    
    func setRedditItem(redditViewItem: RedditViewItem) {
        self.redditViewItem = redditViewItem

        self.thumbnail.image = nil
        self.subscription?.dispose()
        self.subscription = redditViewItem.getThumbnailImage.subscribe(onNext: { image, animate in
            self.thumbnail.image = image
        })
        
        if GlobalPlayer.shared.isActivePlayerItem(item: self.redditViewItem!) {
            self.showPlayerView()
        } else {
            self.showThumbnail()
        }
    }
    
    let disposeBag = DisposeBag()
    
    func showPlayerView(animate: Bool = false) {
        self.myPlayerView.playerLayer.player = GlobalPlayer.shared.player
        self.myPlayerView.playerLayer.setNeedsDisplay()
        self.toggleView(view: self.myPlayerView, alpha: 1, animate: animate)
    }
    
    func showThumbnail(animate: Bool = false) {
        self.toggleView(view: self.myPlayerView, alpha: 0, animate: animate)
    }
    
    func setGlobalPlayerItemSubscription() {
        GlobalPlayer.shared.activeRedditViewItem.subscribe(onNext: { item in
            if self.redditViewItem === item {
                self.showPlayerView(animate: true)
            } else {
                // needs to be false or the current player item flickers out of place for a split second
                self.showThumbnail(animate: false)
            }
        }).disposed(by: self.disposeBag)
    }
    
    @objc func onTap() {
        _ = self.redditViewItem!.updateGlobalPlayer().subscribe()
        self.toggleFullScreenButton()
    }
    
    @objc func fullScreenButtonAction() {
        if let redditViewItem = self.redditViewItem {
            MyNavigation.shared.presentVideoPlayer(redditViewItem: redditViewItem)
        }
    }
    
    func toggleView(view: UIView, alpha: CGFloat, animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = alpha
            })
        } else {
            view.alpha = alpha
        }
    }
    
    var fullScreenTimeoutTask: DispatchWorkItem?
    
    /// hide the full screen button after 3 seconds
    func toggleFullScreenButton() {
        self.fullScreenTimeoutTask?.cancel()
        self.fullScreenTimeoutTask = DispatchWorkItem {
            self.toggleView(view: self.fullScreenButtonContainer, alpha: 0)
        }
        self.toggleView(view: self.fullScreenButtonContainer, alpha: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: self.fullScreenTimeoutTask!)
    }
}
