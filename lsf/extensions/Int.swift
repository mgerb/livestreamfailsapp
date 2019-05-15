//
//  Int.swift
//  haiku
//
//  Created by Mitchell Gerber on 11/4/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation

extension Int {
    private static var commaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    internal var commaRepresentation: String {
        return Int.commaFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
