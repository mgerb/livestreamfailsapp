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
import SwiftSoup

/// service to get direct video url for different service providers
class ClipUrlService: NSObject {
    static let shared = ClipUrlService()

    /// return videoUrl, thumbnailUrl
    func getClipInfo(redditPost: RedditPost, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        // get first comment to check for stickied mirror links from live stream fails bot
        RedditService.shared.getFirstComment(permalink: redditPost.permalink) { comment in
            let queue = [redditPost.url, comment?.body?.liveStreamFails, comment?.body?.streamableUrl]
            self.processUrlQueue(queue: queue.compactMap { $0 }) { res in
                closure(res)
            }
        }
    }
    
    private func processUrlQueue(queue: [String], closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        if queue.count > 0 {
            var queue = queue
            let urlString = queue.removeFirst()
            self.getClipUrl(urlString: urlString) { res in
                if res != (nil, nil) {
                    closure(res)
                } else if queue.count > 0 {
                    self.processUrlQueue(queue: queue) { closure($0) }
                } else {
                    closure((nil, nil))
                }
            }
        } else {
            closure((nil, nil))
        }
    }
    
    private func getClipUrl(urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        if let id = urlString.youtubeID {
            self.getYoutubeUrl(id) { closure($0) }
        } else if let id = urlString.twitchID {
            self.getTwitchUrl(id) { closure($0) }
        } else if urlString.isNeatclipUrl {
            self.getNeatClipUrl(urlString) { closure($0) }
        } else if urlString.isLiveStreamFailsUrl {
            self.getLiveStreamFailsUrl(urlString) { closure($0) }
        } else if urlString.isStreamableUrl {
            self.getStreamableUrl(urlString) { closure($0) }
        } else {
            closure((nil, nil))
        }
    }
    
    private func getYoutubeUrl(_ id: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        let client = XCDYouTubeClient.default()
        client.getVideoWithIdentifier(id) { (info, err) -> Void in
            if let streamUrl =  info?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                ?? info?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                closure((streamUrl, nil))
                return
            }
            closure((nil, nil))
        }
    }

    private func getTwitchUrl(_ id: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        TwitchService.shared.getTwitchClipUrl(clipID: id) { res in
            closure(res)
        }
    }
    
    // TODO:
    private func getNeatClipUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        closure((nil, nil))
    }
    
    private func getLiveStreamFailsUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        self.getUrlsFromHtml(urlString) { closure($0) }
    }
    
    private func getStreamableUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        self.getUrlsFromHtml(urlString) { closure($0) }
    }
    
    /// fetch html page and parse source URL's from video element
    private func getUrlsFromHtml(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        let queue = DispatchQueue(label: "ClipUrlService.getUrlsFromHtml", qos: .utility, attributes: [.concurrent])
        Alamofire.request(urlString).validate().response(queue: queue, responseSerializer: DataRequest.stringResponseSerializer(), completionHandler: { res in
            var videoUrl: URL?, thumbnailUrl: URL?
            
            switch res.result {
            case .success(let val):
                do {
                    let html = try SwiftSoup.parse(val)
                    
                    let videoElem = try html.getElementsByTag("video")
                    let sourceElem = try html.getElementsByTag("source")

                    // for streamable src attribute is on "video" element - for lsf it's on the "source" element
                    let video = sourceElem.isEmpty() ? try videoElem.first()?.attr("src") : try sourceElem.first()?.attr("src")
                    let thumbnail = try videoElem.first()?.attr("poster")

                    // streamable links start with "//" and without https
                    // trim the "//" and add "https" to beginning of string if it doesn't exist
                    if
                        let video = video?.trimmingCharacters(in: CharacterSet.init(charactersIn: "/")),
                        let thumbnail = thumbnail?.trimmingCharacters(in: CharacterSet.init(charactersIn: "/")) {
                        videoUrl = URL(string: video.hasPrefix("https://") ? video : "https://\(video)")
                        thumbnailUrl = URL(string: thumbnail.hasPrefix("https://") ? thumbnail : "https://\(thumbnail)")
                    }
                } catch {
                    // do nothing
                }
            case .failure(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                closure((videoUrl, thumbnailUrl))
            }
        })
    }
}
