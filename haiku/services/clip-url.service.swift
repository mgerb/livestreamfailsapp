//
//  clip-url.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/24/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Alamofire
import XCDYouTubeKit

/// service to get direct video url for different service providers
class ClipUrlService: NSObject {
    static let shared = ClipUrlService()

    func getClipUrl(url: String, urlType: RedditViewItemVideoType, closure: @escaping (_ url: URL?) -> Void) {
    
        switch urlType {
        case .youtube:
            self.getYoutubeUrl(url: url) { closure($0) }
        case .twitch:
            self.getTwitchUrl(url: url) { closure($0) }
        case .neatclip:
            self.getNeatClipUrl(url: url) { closure($0) }
        case .livestreamfails:
            self.getLiveStreamFailsUrl(url: url) { closure($0) }
        case .streamable:
            self.getStreamableUrl(url: url) { closure($0) }
        default:
            closure(nil)
        }
    }
    
    func getYoutubeUrl(url: String, closure: @escaping (_ url: URL?) -> Void) {
        if let id = url.youtubeID {
            let client = XCDYouTubeClient.default()
            client.getVideoWithIdentifier(id) { (info, err) -> Void in
                if let streamUrl =  info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                    ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                    closure(streamUrl)
                    return
                }
                closure(nil)
            }
        } else {
            closure(nil)
        }
    }

    func getTwitchUrl(url: String, closure: @escaping (_ url: URL?) -> Void) {
        if let id = url.twitchID {
            TwitchService.shared.getTwitchClipUrl(clipID: id) { u in
                let url = u != nil ? URL(string: u!) : nil
                closure(url)
            }
        } else {
            closure(nil)
        }
    }
    
    func getNeatClipUrl(url: String, closure: @escaping (_ url: URL?) -> Void) {
        if let test = url.neatclipID {
            
        } else {
            closure(nil)
        }
    }
    
    func getLiveStreamFailsUrl(url: String, closure: @escaping (_ url: URL?) -> Void) {
        if let test = url.liveStreamFails {
            
        } else {
            closure(nil)
        }
    }
    
    func getStreamableUrl(url: String, closure: @escaping (_ url: URL?) -> Void) {
        if let test = url.streamable {
            
        } else {
            closure(nil)
        }
    }
}
