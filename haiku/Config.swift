//
//  Config.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/7/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    let primaryFont: UIColor = .darkGray
    let primaryLight: UIColor = .lightGray
    let primaryLight1: UIColor = UIColor(hexString: "#e0e0e0")
    let primaryLight2: UIColor = UIColor(hexString: "#f7f7f7")
    let red: UIColor = .red
    let white: UIColor = .white
    let blueLink = UIColor(red: 0.204, green: 0.459, blue: 1.000, alpha: 1.0)
}

class Config {
    static let defaultFont = UIFont.systemFont(ofSize: 16)
    static let defaultBoldFont = UIFont.boldSystemFont(ofSize: 16)
    static let smallFont = UIFont.systemFont(ofSize: 12)
    static let smallBoldFont = UIFont.boldSystemFont(ofSize: 12)
    static let colors = Colors()
}
