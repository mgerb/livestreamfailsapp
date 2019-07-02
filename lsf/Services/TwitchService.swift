//
//  twitch.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/22/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import Alamofire
import Marshal

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
                do {
                    let json = try JSONParser.JSONObjectWithData(data)
                    let qualityOptions: [MarshalDictionary] = try json.value(for: "quality_options")
                    // grab the first item in the list - this should always
                    // be the best quality and won't contain the video quality
                    // in the url
                    let primarySource: String = try qualityOptions[0].value(for: "source")
                    
                    // grab the preferred video source url based on quality
                    var preferredSource = try qualityOptions.filter {
                        let quality: String = try $0.value(for: "quality")
                        return quality == UserSettings.shared.getPreferredVideoQuality()
                    }.first?["source"]
                    
                    // set preferred source to primary source if not found
                    if preferredSource == nil {
                        preferredSource = primarySource
                    }
                    
                    if let source = preferredSource as? String {
                        // grab the thumbnail url from the primary source always
                        if let thumbnailUrl = self.grabThumnailUrl(clipUrl: primarySource) {
                            closure((URL(string: source), URL(string: thumbnailUrl)))
                            return
                        }
                    }
                } catch {
                    print(error)
                }

            }
            closure((nil, nil))
        })
    }
    
    func grabThumnailUrl(clipUrl: String?) -> String? {
        return clipUrl?.replacingOccurances(pattern: ".mp4", with: "-preview.jpg")
    }
}
