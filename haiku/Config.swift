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
    // use lightText for dark backgrounds
    let font1: UIColor = .darkText
    let font2: UIColor = .gray
    let bg1: UIColor = .white
    let bg2: UIColor = UIColor(hexString: "#e0e0e0")
    let bg3: UIColor = UIColor(hexString: "#f7f7f7")

    // ios color palette
    let red = UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
    let orange = UIColor(red: 255 / 255, green: 149 / 255, blue: 0 / 255, alpha: 1)
    let yellow = UIColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1)
    let green = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    let tealBlue = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1)
    let blue = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1)
    let purple = UIColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1)
    let pink = UIColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1)
    
    let white: UIColor = .white
}

class Config {
    static let defaultFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
    static let defaultBoldFont = UIFont.boldSystemFont(ofSize: 16)
    static let smallerFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.light)
    static let smallFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
    static let smallBoldFont = UIFont.boldSystemFont(ofSize: 12)
    static let colors = Colors()
}
