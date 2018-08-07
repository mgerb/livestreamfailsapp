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
    private let videos = ["z6A2LHGx8_A", "hKvbaZTAQN0", "mLq_P0K4jvA", "U1KiC0AXhHg", "62M8V-KQnJA"]
    private var data: [PlayerView] = []
    private var myTableView: UITableView!
    private var currentPlayingIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
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
        
        self.view.addSubview(self.myTableView)
        
        self.loadObjects()
    }
    
    func loadObjects() {
        let client = XCDYouTubeClient.default()
        self.videos.forEach{id in
            client.getVideoWithIdentifier(id) { (info, err) -> Void in
                let player = Player()
                player.url = info?.streamURLs[22]
                let playerView = PlayerView()
                playerView.initView(player)
                self.data.append(playerView)
                self.myTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

