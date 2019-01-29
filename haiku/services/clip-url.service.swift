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

struct ClipUrlResponse {
    let videoUrl: URL
    let thumbnailUrl: URL?
}

/// service to get direct video url for different service providers
class ClipUrlService: NSObject {
    static let shared = ClipUrlService()

    func getClipUrl(redditPost: RedditPost, urlType: RedditViewItemVideoType, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
    
        if let id = redditPost.url?.youtubeID {
            self.getYoutubeUrl(id: id) { closure($0) }
        } else if let id = redditPost.url?.twitchID {
            self.getTwitchUrl(id: id) { closure($0) }
        } else if let url = redditPost.url?.neatclipID {
            self.getNeatClipUrl(url: url) { closure($0) }
        } else if let url = redditPost.url?.liveStreamFails {
            self.getLiveStreamFailsUrl(url: url) { closure($0) }
        } else if let url = redditPost.url?.streamable {
            self.getStreamableUrl(url: url) { closure($0) }
        } else {
            closure(nil)
        }
    }
    
    func getYoutubeUrl(id: String, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
        let client = XCDYouTubeClient.default()
        client.getVideoWithIdentifier(id) { (info, err) -> Void in
            if let streamUrl =  info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                closure(ClipUrlResponse(videoUrl: streamUrl, thumbnailUrl: nil))
                return
            }
            closure(nil)
        }
    }

    func getTwitchUrl(id: String, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
        TwitchService.shared.getTwitchClipUrl(clipID: id) { res in
            closure(res)
        }
    }
    
    func getNeatClipUrl(url: String, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
        if let test = url.neatclipID {
            
        } else {
            closure(nil)
        }
    }
    
    func getLiveStreamFailsUrl(url: String, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
        if let test = url.liveStreamFails {
            
        } else {
            closure(nil)
        }
    }
    
    func getStreamableUrl(url: String, closure: @escaping (_ url: ClipUrlResponse?) -> Void) {
        if let test = url.streamable {
            
        } else {
            closure(nil)
        }
    }
}
