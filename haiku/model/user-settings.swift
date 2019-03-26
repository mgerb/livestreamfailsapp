//
//  user-settings.swift
//  haiku
//
//  Created by Mitchell Gerber on 3/24/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Realm
import RealmSwift

enum SettingType {
    case toggle
    case button
    case option
}

struct SettingInfo {
    let key: String
    let label: String
    let description: String?
    let type: SettingType
    let handler: ((_: Any?) -> ())?
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

    var nsfw: Bool = false

    enum CodingKeys: String, CodingKey {
        case nsfw = "nsfw"
    }
    
    // 2d array for sections
    var info: [[SettingInfo]] = [[
        SettingInfo(key: "nsfw", label: "Show not safe for work content", description: nil, type: .toggle, handler: { isOn in
            if let isOn = isOn as? Bool {
                UserSettings.shared.nsfw = isOn
                UserSettings.shared.syncSettings()
            }
        }),
        SettingInfo(key: "clearCache", label: "Clear Cache", description: nil, type: .button, handler: { _ in
            StorageService.shared.clearDiskCache()
        }),
    ]]

    func getSettingValue(key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        return mirror.descendant(key)
    }
    
    func syncSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserSettings.storageKey)
        }
    }
}

