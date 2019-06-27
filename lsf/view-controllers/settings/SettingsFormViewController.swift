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

    lazy var loginSection = Section(RedditService.shared.user?.name ?? "")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.setForm()
    }
    
    func setForm() {
        
        self.form
            +++ Section(header: "Video quality preferences", footer: "Increasing the video quality significantly increases data used.")
            <<< PushRow<String>() { row in
                row.title = "Wifi Data"
                row.value = UserSettings.shared.wifiVideoQuality.rawValue
                row.options = VideoQuality.allCases.map { $0.rawValue }
                }.onChange { change in
                    if let val = change.value, let quality = VideoQuality(rawValue: val) {
                        UserSettings.shared.wifiVideoQuality = quality
                    }
            }
            <<< PushRow<String>() { row in
                row.title = "Cellular Data"
                row.value = UserSettings.shared.cellVideoQuality.rawValue
                row.options = VideoQuality.allCases.map { $0.rawValue }
                }.onChange { change in
                    if let val = change.value, let quality = VideoQuality(rawValue: val) {
                        UserSettings.shared.cellVideoQuality = quality
                    }
            }
            
            +++ Section()
            <<< self.clearHiddenPostsButton
            
            +++ Section("Caching")
            <<< SwitchRow() { row in
                row.title = "Cache Videos"
                row.value = UserSettings.shared.cacheVideos
                row.onChange() { sw in
                    UserSettings.shared.cacheVideos = sw.value ?? true
                }
            }
            <<< self.cacheButtonRow
            
            +++ self.loginSection
            <<< ButtonRow() { row in
                row.title = RedditService.shared.user == nil ? "Login" : "Logout"
                row.cellStyle = .value1
                row.onCellSelection { _, _  in
                    if RedditService.shared.user != nil {
                        RedditService.shared.logout()
                        row.title = "Login"
                        self.loginSection.header?.title = ""
                        self.loginSection.reload()
                        row.reload()
                    } else {
                        let controller = RedditAuthViewController()
                        controller.loginSuccess = {
                            row.title = "Logout"
                            self.loginSection.header?.title = RedditService.shared.user?.name
                            self.loginSection.reload()
                            row.reload()
                        }
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cacheButtonRow.value = StorageService.shared.getDocumentDirecorySize()
        self.cacheButtonRow.reload()
    }
}
