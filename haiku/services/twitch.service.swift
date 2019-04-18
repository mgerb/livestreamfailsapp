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

class TwitchService {
    static let shared = TwitchService()

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
                
                
                // grab the first item in the list - this should always
                // be the best quality and won't contain the video quality
                // in the url
                let primarySource = JSON(data)["quality_options"][0]["source"]
                
                // grab the preferred video source url based on quality
                var preferredSource = JSON(data)["quality_options"].array?.filter { $0["quality"].string == UserSettings.shared.videoQuality.rawValue }.first
                
                // set preferred source to primary source if not found
                if preferredSource == nil {
                    preferredSource = primarySource
                }

                if let source = preferredSource {
                    // grab the thumbnail url from the primary source always
                    if let clipUrl = source.string, let thumbnailUrl = self.grabThumnailUrl(clipUrl: primarySource.string) {
                        closure((URL(string: clipUrl), URL(string: thumbnailUrl)))
                        return
                    }
                }
            }
            closure((nil, nil))
        })
    }
    
    func grabThumnailUrl(clipUrl: String?) -> String? {
        return clipUrl?.replacingOccurances(pattern: ".mp4", with: "-preview.jpg")
    }
}
