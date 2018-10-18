//
//  Util.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/17/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class Util {
    private static let impactFeedback = UIImpactFeedbackGenerator()
    private static let notificationFeedback = UINotificationFeedbackGenerator()

    static func hapticFeedback() {
        self.impactFeedback.impactOccurred()
    }
    
    static func hapticFeedbackSuccess() {
        self.notificationFeedback.notificationOccurred(.success)
    }
}
