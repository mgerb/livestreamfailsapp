//
//  clip-url.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/24/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import XCDYouTubeKit
import Alamofire
import SwiftSoup

/// service to get direct video url for different service providers
class ClipUrlService: NSObject {
    static let shared = ClipUrlService()

    /// return videoUrl, thumbnailUrl
    func getClipInfo(redditLink: RedditLink, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        
        // get first comment to check for stickied mirror links from live stream fails bot
        RedditService.shared.getFirstComment(permalink: redditLink.permalink) { comment in
            let queue = [redditLink.url, comment?.body.liveStreamFails, comment?.body.streamableUrl]
            self.processUrlQueue(queue: queue.compactMap { $0 }) { res in
                closure(res)
            }
        }
        
        // TODO: skip for now need to find way to combine audio with video - see python script
//        DispatchQueue.global().async {
//
//            let dispatchGroup = DispatchGroup()
//            var videoUrl, thumbnailUrl: URL?
//
//            dispatchGroup.enter()
//
//            self.getRedditVideoUrl(redditLink: redditLink, closure: { (v, t) in
//                videoUrl = v
//                thumbnailUrl = t
//                dispatchGroup.leave()
//            })
//
//            dispatchGroup.wait()
//
//            if let videoUrl = videoUrl, let thumbnailUrl = thumbnailUrl {
//                DispatchQueue.main.async {
//                    closure((videoUrl, thumbnailUrl))
//                }
//                return
//            }
//        }
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
    
    private func getRedditVideoUrl(redditLink: RedditLink, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        if let fallbackUrl = redditLink.fallbackUrl {
            RedditService.shared.checkRedditVideo(fallbackUrl: fallbackUrl, closure: { valid in
                if valid, let videoUrl = URL(string: fallbackUrl), let previewUrl = redditLink.previewUrl, let thumbnailUrl = URL(string: previewUrl) {
                    closure((videoUrl, thumbnailUrl))
                } else {
                    closure((nil, nil))
                }
            })
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
    
    private func getNeatClipUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        self.getUrlsFromHtml(urlString) { closure($0) }
    }
    
    private func getLiveStreamFailsUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        self.getUrlsFromHtml(urlString) { closure($0) }
    }
    
    private func getStreamableUrl(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        self.getUrlsFromHtml(urlString) { closure($0) }
    }
    
    /// fetch html page and parse source URL's from meta tags
    private func getUrlsFromHtml(_ urlString: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> Void) {
        let queue = DispatchQueue(label: "ClipUrlService.getUrlsFromHtml", qos: .utility, attributes: [.concurrent])
        Alamofire.request(urlString).validate().response(queue: queue, responseSerializer: DataRequest.stringResponseSerializer(), completionHandler: { res in
            var videoUrl: URL?, thumbnailUrl: URL?
            
            switch res.result {
            case .success(let val):
                do {
                    let html = try SwiftSoup.parse(val)
                    
                    var vUrl = try html.getElementsByAttributeValue("property", "og:video:url")

                    if vUrl.first() == nil {
                        vUrl = try html.getElementsByAttributeValue("property", "og:video")
                    }
                    
                    let iUrl = try html.getElementsByAttributeValue("property", "og:image")

                    if let vUrl = try vUrl.first()?.attr("content"), let iUrl = try iUrl.first()?.attr("content") {
                        videoUrl = URL(string: vUrl)
                        thumbnailUrl = URL(string: iUrl)
                    }
                } catch {
                    print(error)
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
