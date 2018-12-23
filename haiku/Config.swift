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
    let red: UIColor = .red
    let white: UIColor = .white
}

class Config {
    static let defaultFont = UIFont.systemFont(ofSize: 16)
    static let smallFont = UIFont.systemFont(ofSize: 12)
    static let colors = Colors()
}
