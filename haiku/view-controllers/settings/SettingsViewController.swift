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
        
        self.tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // set to value needed
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "test footer"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test title"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.textLabel?.text = "Clear Cache"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = Config.colors.blue
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = "Cell at row \(indexPath.row)"
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        cell.textLabel?.textColor = Config.colors.blue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0  {
            StorageService.shared.clearVideoCache()
            self.tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        print(sender.tag)
        print(sender.isOn)
    }
    
}
