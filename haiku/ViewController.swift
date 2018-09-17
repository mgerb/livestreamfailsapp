//
//  ViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 8/6/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit

import SnapKit
import Player
import XCDYouTubeKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var data: [PlayerView] = []
    private var myTableView: UITableView!
    private var currentPlayingIndex: Int?
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)

        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // setup table view
        self.myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        self.myTableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.estimatedRowHeight = 80
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.separatorStyle = .none
        self.myTableView.showsVerticalScrollIndicator = false
        self.myTableView.estimatedRowHeight = (self.view.frame.width * 9 / 16) + 20
        
        if #available(iOS 10.0, *) {
            self.myTableView.refreshControl = refreshControl
        } else {
            self.myTableView.addSubview(refreshControl)
        }
        
        self.refreshControl.addTarget(self, action: #selector(loadNewObjects), for: .valueChanged)
        
        self.view.addSubview(self.myTableView)
        
        self.loadObjects(after: nil)
    }

    // video gets paused when entering background so reset current playing
    @objc func appMovedToBackground() {
        self.currentPlayingIndex = nil
    }
    
    @objc func loadNewObjects() {
        self.loadObjects(after: nil)
    }
    
    func loadObjects(after: String?) {
        if (!self.refreshControl.isRefreshing) {
            self.refreshControl.beginRefreshing()
        }
        RedditService.shared.getHaikus(after: after){ redditPosts in
            self.pauseCurrentTrack()
            self.currentPlayingIndex = nil

            let items: [PlayerView] = redditPosts.compactMap{ post in
                if post.url?.youtubeID == nil {
                    return nil
                }
                let newPlayer = PlayerView(post.url!.youtubeID!)
                newPlayer.redditPost = post
                newPlayer.isReady = { () in
                    // stop listening after set
                    newPlayer.isReady = nil
                    DispatchQueue.main.async{
                        self.myTableView.reloadData()
                    }
                    if (self.refreshControl.isRefreshing) {
                        self.refreshControl.endRefreshing()
                    }
                }
                return newPlayer
            }
            
            if (after == nil) {
                self.data = items
            } else {
                self.data += items
            }
            DispatchQueue.main.async{
                self.myTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let playerView: PlayerView = data[indexPath.row]
        return playerView.player.url != nil ? playerView.getHeight(self.view.frame.width) + 20 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.currentPlayingIndex != nil {
            data[self.currentPlayingIndex!].togglePlaying()
            if self.currentPlayingIndex == indexPath.row {
                self.currentPlayingIndex = nil
                return
            }
        }

        data[indexPath.row].togglePlaying()
        self.currentPlayingIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath as IndexPath) as! VideoCell
        cell.load(playerView: data[indexPath.row])
        return cell
    }
    
    // currently not working
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let  height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if distanceFromBottom < height && data.count > 0 && !self.refreshControl.isRefreshing {
//            if let id = data[data.count - 1].redditPost?.id {
//                print("loading more data")
//                self.loadObjects(after: id)
//            }
//        }
//    }

    func pauseCurrentTrack() {
        if (self.currentPlayingIndex != nil) {
            self.data[self.currentPlayingIndex!].player.pause()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

