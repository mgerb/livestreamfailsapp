//
//  MyNavigation.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/13/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class MyNavigation {
    let shared = MyNavigation()
    private let rootViewController = UIApplication.shared.keyWindow!.rootViewController
    
    func presentWebView() {
        let navController = UINavigationController(rootViewController: WebViewController())
        self.rootViewController?.present(navController, animated: true)
    }
}
