//
//  TapThroughTextView.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/15/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class CommentsTextView: UITextView, UITextViewDelegate {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedTextView(tapGesture:)))
        self.addGestureRecognizer(tapRecognizer)
        
        self.delegate = self
        self.textDragInteraction?.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let url = self.getTappedUrl(url: URL) {
            MyNavigation.shared.presentWebView(url: url)
        }
        return false
    }
    
    @objc func tappedTextView(tapGesture: UIGestureRecognizer) {
        let tapLocation = tapGesture.location(in: self)
        let url = self.getUrlAtPoint(point: tapLocation)
        if let url = self.getTappedUrl(url: url?.absoluteURL) {
            MyNavigation.shared.presentWebView(url: url)
        }
    }
    
    /// prevent normal text inside view from being tapped while still allowing lnks
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let val = self.getUrlAtPoint(point: point)
        return self.getTappedUrl(url: val?.absoluteURL) != nil
    }
    
    private func getUrlAtPoint(point: CGPoint) -> NSURL? {
        guard let pos = closestPosition(to: point) else { return nil }
        
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: UITextLayoutDirection.left.rawValue) else { return nil }
        
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(NSAttributedStringKey.link, at: startIndex, effectiveRange: nil) as? NSURL
    }
    
    // if a tapped url is a subreddit e.g. r/all
    // append it to full url - else return url
    private func getTappedUrl(url: URL?) -> URL? {
        
        guard let url = url else { return nil }
        
        if url.absoluteString.matches(pattern: "^https?") {
            return url
        }
        
        print(url.path)
        if url.path.matches(pattern: "^\\/?(r|u)\\/[\\w\\d-]+") == true {
            return URL(string: "https://www.reddit.com\(url.path)")
        }
        
        return nil
    }
}
