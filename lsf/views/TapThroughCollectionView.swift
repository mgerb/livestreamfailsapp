//
//  TapThroughCollectionViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/6/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class TapThroughCollectionView: UICollectionView {

    /// tap events go through unless tapped outside of a view cell
    /// this makes it so that we can still tap on the videos
    /// when the collection view is scrolled down the page
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView is TapThroughCollectionView {
                return nil
            } else {
                return hitView
            }
        } else {
            return nil
        }
    }
}
