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
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // pause player when user navigates to another tab
        GlobalPlayer.shared.pause()
    }
}
