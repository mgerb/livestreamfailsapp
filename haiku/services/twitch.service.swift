//
//  twitch.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/22/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum VideoQuality: String {
    case _360 = "360"
    case _480 = "480"
    case _720 = "720"
    case _1080 = "1080"
}

class TwitchService {
    static let shared = TwitchService()
    
    private let videoQuality = VideoQuality._480

    /* Format example:
         {
             "quality_options": [{
                 "source" : "https:\/\/clips-media-assets2.twitch.tv\/150987305.mp4",
                 "frame_rate" : 30,
                 "quality" : "1080"
             }]
         }
     */
    func getTwitchClipUrl(clipID: String, closure: @escaping (_ urlTuple: (URL?, URL?)) -> ()) {
        let urlString = "https://clips.twitch.tv/api/v2/clips/\(clipID)/status"
        Alamofire.request(urlString).response(completionHandler: { res in
            if let data = res.data {
                // this will need to be changed when the user has the option to change video quality
                var videoJson = JSON(data)["quality_options"].array?.filter { $0["quality"].string == self.videoQuality.rawValue }.first
                
                // if we can't find the quality we are looking for grab the first in the list
                if videoJson == nil {
                    videoJson = JSON(data)["quality_options"].array?.first
                }
                
                if let v = videoJson {
                    if let clipUrl = v["source"].string, let thumbnailUrl = self.grabThumnailUrl(clipUrl: clipUrl) {
                        closure((URL(string: clipUrl), URL(string: thumbnailUrl)))
                        return
                    }
                }
            }
            closure((nil, nil))
        })
    }
    
    // TODO: video quality type
    func grabThumnailUrl(clipUrl: String?) -> String? {
        
        var newUrl = clipUrl
        
        if newUrl?.contains("AT-") == true {
            if newUrl?.contains("offset") == true {
                newUrl = clipUrl?.replacingOccurrences(of: "AT-cm%7C", with: "")
            } else if newUrl?.contains("cm%7C") == false {
                newUrl = clipUrl?.replacingOccurrences(of: "AT-", with: "")
            }
        }
        
        // maybe use this for smalles thumbnails, but I worry that this url link may not exist
//        newUrl = newUrl?.replacingOccurances(pattern: "(-[\\w\\d]*)?.mp4", with: "-preview-480x272.jpg")
        newUrl = newUrl?.replacingOccurances(pattern: "(-[\\w\\d]*)?.mp4", with: "-preview.jpg")
        
        return newUrl
    }
}
