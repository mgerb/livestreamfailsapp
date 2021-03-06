//
//  String.swift
//  haiku
//
//  Created by Mitchell Gerber on 9/26/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

extension String: Differentiable {
    
    /// check if matches regex pattern
    func matches(pattern: String) -> Bool {
        let range = NSRange(location: 0, length: self.count)
        let r = try? NSRegularExpression(pattern: pattern, options: .init())
        
        if r?.firstMatch(in: self, options: [], range: range) == nil {
            return false
        }
        
        return true
    }
    
    /// extract youtube id from twitch url
    var youtubeID: String? {

        let workingString = self.replaceEncoding()
        let range = NSRange(location: 0, length: workingString.count)

        // check if valid youtube url first
        let p = "((?:https?:)?\\/\\/)?((?:www|m)\\.)?(youtube\\.com|youtu.be)"
        let r = try? NSRegularExpression(pattern: p, options: .caseInsensitive)
        
        if r?.firstMatch(in: workingString, options: [], range: range) == nil {
            return nil
        }
        
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&|;)v=)|(?<=embed/))([\\w-]++)"
        return self.extractText(pattern: pattern)
    }
    
    /// extract twitch id from twitch url
    var twitchID: String? {
        let pattern = "(?<=(https:\\/\\/)?(?:clips|www)\\.twitch\\.tv\\/)([\\w-\\/]++)"
        if let subString = self.extractText(pattern: pattern)?.split(separator: "/").last {
            return String(subString)
        } else {
            return nil
        }
    }

    var isNeatclipUrl: Bool {
        return self.contains("neatclip.com")
    }

    /// extract url from markdown
    var liveStreamFails: String? {
        let pattern = "(?<=\\()((https:\\/\\/)?(www\\.)?livestreamfails\\.com\\/post\\/[\\w-]++)"
        return self.extractText(pattern: pattern)
    }
    
    var isLiveStreamFailsUrl: Bool {
        return self.contains("livestreamfails.com")
    }

    /// extract url from markdown
    var streamableUrl: String? {
        let pattern = "(?<=\\()((https:\\/\\/)?(www\\.)?streamable\\.com\\/[\\w-]++)"
        return self.extractText(pattern: pattern)
    }
    
    var isStreamableUrl: Bool {
        return self.contains("streamable.com")
    }
    
    func extractText(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.count)
        
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
        return ceil(boundingBox.height)
    }

    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(boundingBox.width)
    }

    func replaceEncoding() -> String {
        return self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    /// replaces normal links with markdown formatted links
    func replaceLinksWithMarkdown() -> String {
        let regex = try! NSRegularExpression(pattern: "(^|[\\n\\r\\s]+)(https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))")
        let range = NSMakeRange(0, self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range:range , withTemplate: "$1[$2]($2)")
    }
    
    var isValidUrl: Bool {
        // create NSURL instance
        if let url = URL(string: self) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// regex pattern
    func replacingOccurances(pattern: String, with: String) -> String {
        let value = NSMutableString(string: self)
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress, range: NSRange(location: 0,length: value.length), withTemplate: with)
        return String(value)
    }
    
    func getBaseUrl() -> String? {
        let url = URL(string: self)
        
        let baseURL = url?.host
        
        return baseURL
    }
}
