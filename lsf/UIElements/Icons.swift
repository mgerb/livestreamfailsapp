//
//  icons.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

enum MyIconType: String {
    case arrowDown = "\u{e900}"
    case arrowUp = "\u{e901}"
    case commentFill = "\u{e902}"
    case comment = "\u{e903}"
    case dotsFill = "\u{e904}"
    case dots = "\u{e905}"
    case heartFill = "\u{e906}"
    case heart = "\u{e907}"
    case search = "\u{e908}"
    case settingsFill = "\u{e909}"
    case settings = "\u{e90a}"
    case tvFill = "\u{e90b}"
    case tv = "\u{e90c}"
    case link = "\u{e90d}"
    case userFill = "\u{e90e}"
    case user = "\u{e90f}"
}

extension UILabel {
    func updateIcon(icon: MyIconType, color: UIColor?) {
        self.text = icon.rawValue
        if let color = color {
            self.textColor = color
        }
    }
}

class Icons {

    static func getLabel(icon: MyIconType, size: CGFloat = 25, color: UIColor? = Config.colors.primaryFont, target: Any? = nil, action: Selector? = nil) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "icomoon", size: size)
        label.text = icon.rawValue
        
        if let color = color {
            label.textColor = color
        }
        
        if let target = target, let action = action {
            label.isUserInteractionEnabled = true
            let g = UITapGestureRecognizer(target: target, action: action)
            label.addGestureRecognizer(g)
        }
        
        return label
    }
    
    static func getImage(icon: MyIconType, size: CGFloat, color: UIColor) -> UIImage? {
        if size == 0.0 {
            return nil
        }
        
        var attributes = [NSAttributedStringKey: Any]()
        attributes[NSAttributedStringKey.font] = UIFont(name: "icomoon", size: size)
        attributes[NSAttributedStringKey.foregroundColor] = color
        
        let attributedString = NSAttributedString(string: icon.rawValue, attributes: attributes)
        
        let mutableSymbol = NSMutableAttributedString(attributedString: attributedString)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        mutableSymbol.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableSymbol.length))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        mutableSymbol.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func getTabBarItem(icon: MyIconType, selectedIcon: MyIconType, tag: Int) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: nil, image: nil, tag: tag)
        tabBarItem.image = Icons.getImage(icon: icon, size: 25, color: Config.colors.secondaryFont)
        tabBarItem.selectedImage = Icons.getImage(icon: selectedIcon, size: 25, color: Config.colors.secondaryFont)
        return tabBarItem
    }
    
}
