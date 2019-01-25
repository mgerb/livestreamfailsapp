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
    
    let clientID = "eg7khq6cjta595v7e908zofht88e03"
    // e.g. https://api.twitch.tv/kraken/clips/SolidSincereDiscMcaT
    let clipsBaseUrl = "https://api.twitch.tv/kraken/clips/"
    let clipDirectBaseUrl = "https://clips-media-assets2.twitch.tv/AT-cm%7C{{replace}}-480.mp4"
    
    lazy var headers = [
        "client-id": self.clientID,
        "Accept": "application/vnd.twitchtv.v5+json"
    ]
    
    func getTwitchClipUrl(clipID: String, closure: @escaping (_ url: String?) -> Void) {
        let url = self.clipsBaseUrl + clipID
        Alamofire.request(url, headers: self.headers).responseData{ response in
            switch response.result {
            case .success(let res):
                closure(self.getClipUrl(json: JSON(res)))
                break
            case .failure(_):
                closure(nil)
            }
        }
    }
    
    private func getClipUrl(json: JSON) -> String? {

        // get mp4 url from thumbnail url's
        // this way we can grab the offset if provided
        if let small = json["thumbnails"]["small"].string {
            if let parts = small.extractText(pattern: "(\\d*(-offset-\\d*)?(?=-preview))") {
                return self.clipDirectBaseUrl.replacingOccurrences(of: "{{replace}}", with: parts)
            }
        }
        
        return nil
    }
}
