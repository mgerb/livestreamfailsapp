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
    
    /// get regex match - case insensitive
    static func getMatch(_ str: String, _ pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: str.count)
        
        guard let result = regex?.firstMatch(in: str, options: [], range: range) else {
            return nil
        }
        
        return (str as NSString).substring(with: result.range)
    }
    
    /// get a query string param
    static func getQueryStringParameter(_ url: String, _ param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
