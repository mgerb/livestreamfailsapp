//
//  TapThroughTextView.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/15/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class TapThroughTextView: UITextView, UITextViewDelegate {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        MyNavigation.shared.presentWebView(url: URL)
        return false
    }
    
    /// TODO: parse short reddit URL's such as "r/all"
    /// prevent normal text inside view from being tapped while still allowing lnks
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let pos = closestPosition(to: point) else { return false }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: UITextLayoutDirection.left.rawValue) else { return false }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        let val = attributedText.attribute(NSAttributedStringKey.link, at: startIndex, effectiveRange: nil) as? NSURL

        return val?.absoluteString?.isValidUrl == true
    }
}
