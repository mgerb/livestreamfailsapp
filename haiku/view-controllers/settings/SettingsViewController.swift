//
//  SettingsViewController.swift
//  haiku
//
//  Created by Mitchell Gerber on 11/4/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        
        self.tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserSettings.shared.info.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSettings.shared.info[section].count // set to value needed
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.getCell(setting: UserSettings.shared.info[indexPath.section][indexPath.row], indexPath: indexPath)
    }
    
    // reload tableview data to reload cache size
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    private func getCell(setting: SettingInfo, indexPath: IndexPath) -> UITableViewCell {
        self.tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        switch setting.type {
        case .button:
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingsCell")
            cell.textLabel?.text = setting.label
            cell.textLabel?.textColor = Config.colors.blue

            if setting.key == .clearCache {
                cell.detailTextLabel?.text = "\(StorageService.shared.getDocumentDirecorySize()) mb"
            }
            return cell
        case .toggle:
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "SettingsCell")
            cell.textLabel?.text = setting.label
            let switchView = MyUISwitch(frame: .zero)
            switchView.indexPath = indexPath
            let val = UserSettings.shared.getSettingValue(key: setting.key) as? Bool ?? false
            switchView.setOn(val, animated: false)
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            return cell
        default:
            break
        }
        
        return self.tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = UserSettings.shared.info[indexPath.section][indexPath.row]
        if case .button = setting.type {
            if setting.key == .clearCache {
                setting.handler?(nil)
                self.tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @objc func switchChanged(_ sender: MyUISwitch) {
        if let indexPath = sender.indexPath {
            let setting = UserSettings.shared.info[indexPath.section][indexPath.row]
            setting.handler?(sender.isOn)
        }
    }
    
}
