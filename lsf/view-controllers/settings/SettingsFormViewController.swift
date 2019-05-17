//
//  SettingsFormViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 4/17/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class SettingsFormViewController: FormViewController {
    
    let cacheButtonRow: ButtonRowOf<String> = ButtonRow() { row in
        row.title = "Clear Cache"
        row.cellStyle = .value1
        row.value = StorageService.shared.getDocumentDirecorySize()
        row.displayValueFor = { $0 }
        
        row.onCellSelection { _, _  in
            StorageService.shared.clearDocumentDirectoryCache()
            row.value = StorageService.shared.getDocumentDirecorySize()
            row.updateCell()
        }
    }
    
    let clearHiddenPostsButton: ButtonRowOf<String> = ButtonRow() { row in
        row.title = "Reset Hidden Clips"
        row.cellStyle = .value1
        row.onCellSelection { _, _  in
            StorageService.shared.clearHiddenPosts()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Settings"
        
        self.form
            +++ Section(header: "Videos", footer: "Increasing the video quality significantly increases data used.")
            <<< SwitchRow()  { row in
                row.title = "Show NSFW content"
                row.value = UserSettings.shared.nsfw
                row.onChange() { sw in
                    UserSettings.shared.nsfw = sw.value ?? false
                }
            }
            <<< self.clearHiddenPostsButton
            <<< PushRow<String>() { row in
                row.title = "Preferred Video Quality"
                row.value = UserSettings.shared.videoQuality.rawValue
                row.options = VideoQuality.allCases.map { $0.rawValue }
                }.onChange { change in
                    if let val = change.value, let quality = VideoQuality(rawValue: val) {
                        UserSettings.shared.videoQuality = quality
                    }
                }

            +++ Section("Caching")
            <<< SwitchRow() { row in
                row.title = "Cache Videos"
                row.value = UserSettings.shared.cacheVideos
                row.onChange() { sw in
                    UserSettings.shared.cacheVideos = sw.value ?? true
                }
            }
            <<< self.cacheButtonRow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cacheButtonRow.value = StorageService.shared.getDocumentDirecorySize()
        self.cacheButtonRow.reload()
    }
}
