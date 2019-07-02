//
//  TapThroughTableView.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/12/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class TapThroughTableView: UITableView {
    
    /// tap events go through unless tapped outside of a view cell
    /// this makes it so that we can still tap on the videos
    /// when the table view is scrolled down the page
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView is TapThroughTableView {
                return nil
            } else {
                return hitView
            }
        } else {
            return nil
        }
    }
}
