//
//  labels.swift
//  haiku
//
//  Created by Mitchell Gerber on 3/26/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

enum MyFontType {
    case regular
    case regularBold
    case small
    case smallBold
    case tiny
}

enum MyFontColor {
    case primary
    case secondary
    case blue
    case white
    case tealBlue
}

enum MyAccentColor {
    case red
}

class Labels {
    
    static func new(font: MyFontType = .regular, color: MyFontColor = .primary, target: Any? = nil, action: Selector? = nil) -> UILabel {
        let label = UILabel()
        
        switch font {
        case .regular:
            label.font = Config.regularFont
        case .regularBold:
            label.font = Config.regularBoldFont
        case .small:
            label.font = Config.smallFont
        case .smallBold:
            label.font = Config.smallBoldFont
        case .tiny:
            label.font = Config.tinyFont
        }
        
        switch color {
        case .primary:
            label.textColor = Config.colors.primaryFont
        case .secondary:
            label.textColor = Config.colors.secondaryFont
        case .blue:
            label.textColor = Config.colors.blue
        case .white:
            label.textColor = Config.colors.white
        case .tealBlue:
            label.textColor = Config.colors.tealBlue
        }
        
        if let target = target, let action = action {
            label.isUserInteractionEnabled = true
            let g = UITapGestureRecognizer(target: target, action: action)
            label.addGestureRecognizer(g)
        }

        return label
    }
    
    static func newAccent(font: MyFontType = .small, color: MyAccentColor = .red) -> UILabel {
        let label = Labels.new(font: font)
        
        label.layer.cornerRadius = 5
        
        switch color {
        case .red:
            label.textColor = Config.colors.white
            label.layer.backgroundColor = Config.colors.red.cgColor
            label.frame.size.width = label.intrinsicContentSize.width + 20
            label.frame.size.height = label.intrinsicContentSize.height + 20
            label.textAlignment = .center
        }
        
        return label
    }
    
    static func nsfwLabel() -> UILabel {
        let label = Labels.newAccent(color: .red)
        label.text = "NSFW"
        return label
    }
}
