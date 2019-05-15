//
//  NSMutableAttributedString.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/16/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    /// remove trailing \n from content
    func trimEndingNewLine() -> NSMutableAttributedString {
        if let lastCharacter = self.string.last, lastCharacter == "\n" {
            self.deleteCharacters(in: NSRange(location: self.length - 1, length: 1))
        }
        return self
    }
}
