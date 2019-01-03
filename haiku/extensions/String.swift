//
//  String.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
    
    /// parse the end time in seconds from youtube URL
    var youtubeEndTime: Int? {
        let end = Util.getQueryStringParameter(self, "end")
        return end != nil ? Int(end!) : nil
    }
    
    /// parse the start time in seconds from youtube URL
    var youtubeStartTime: Int? {
        
        func getSeconds(hours: String?, minutes: String?, seconds: String?) -> Int? {
            var totalTime: Int = 0
            
            if seconds != nil {
                totalTime += Int(seconds!)!
            }
            
            if minutes != nil {
                totalTime += (Int(minutes!)! * 60)
            }
            
            if hours != nil {
                totalTime += (Int(hours!)! * 60 * 60)
            }
            
            return totalTime
        }
        
        // can only be integer value if start param
        if let start = Util.getQueryStringParameter(self, "start") {
            if let seconds = Int(start) {
                return seconds
            }
        }
        
        if let time = Util.getQueryStringParameter(self, "t") {
            // return if time is only an integer
            if let intTime = Int(time) {
                return intTime
            } else {
                // parse hours/minutes/seconds
                let seconds = Util.getMatch(time, "\\d*(?=s)")
                let minutes = Util.getMatch(time, "\\d*(?=m)")
                let hours = Util.getMatch(time, "\\d*(?=h)")
                return getSeconds(hours: hours, minutes: minutes, seconds: seconds)
            }
        }
        
        return nil
    }

    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
    
    func replaceEncoding() -> String {
        return self.replacingOccurrences(of: "&amp;", with: "&")
    }
}
