//
//  MyTabBarController.swift
//  haiku
//
//  Created by Mitchell Gerber on 11/11/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import UIKit
import RxSwift
import AVKit

class MyTabBarController: UITabBarController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupSubjectSubscriptions()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // pause player when user navigates to another tab
        GlobalPlayer.shared.pause()
    }

    func setupSubjectSubscriptions() {
        Subjects.shared.moreButtonAction.subscribe(onNext: { redditViewItem in
            let alertController = RedditAlertController(redditViewItem: redditViewItem)
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
}
