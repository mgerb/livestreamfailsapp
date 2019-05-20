//
//  user-settings.swift
//  haiku
//
//  Created by Mitchell Gerber on 3/24/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Realm
import RealmSwift

enum VideoQuality: String, Codable, CaseIterable {
    case _360 = "360"
    case _480 = "480"
    case _720 = "720"
    case _1080 = "1080"
}

class UserSettings: Object, Codable {
    
    static let storageKey = "UserSettings"

    static let shared: UserSettings = {
        let decoder = JSONDecoder()
        
        guard
            let data = UserDefaults.standard.object(forKey: UserSettings.storageKey) as? Data,
            let userSettings = try? decoder.decode(UserSettings.self, from: data)
        else {
            return UserSettings()
        }

        return userSettings
    }()
    
    enum CodingKeys: String, CodingKey {
        case videoQuality = "videoQuality"
        case cacheVideos = "cacheVideos"
    }

    var videoQuality = VideoQuality._480 {
        didSet {
            self.syncSettings()
        }
    }
    
    var cacheVideos = true {
        didSet {
            self.syncSettings()
        }
    }

    func syncSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserSettings.storageKey)
        }
    }
}

