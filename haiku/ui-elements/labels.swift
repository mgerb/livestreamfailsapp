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
}

class Labels {
    
    static func new(font: MyFontType = .regular, color: MyFontColor = .primary) -> UILabel {
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
        }

        return label
    }
    
}
