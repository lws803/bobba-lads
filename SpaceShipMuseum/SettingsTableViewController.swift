//
//  SettingsTableViewController.swift
//  NASA_Hackathon
//
//  Created by Lynn Bao on 10/19/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var elementDict : [Dictionary<String, String>] = []
    override func viewDidLoad() {
        elementDict.append([
            "name":"element1",
            "melting": "1",
            "boiling": "2"
        ])
        self.tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // call JJ's endpoint
        // process the json into dict by element name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.accessoryType = .none
        
        let elementLabel : UILabel = cell.contentView.viewWithTag(1) as! UILabel
        let meltingLabel : UILabel = cell.contentView.viewWithTag(2) as! UILabel
        let boilingLabel : UILabel = cell.contentView.viewWithTag(3) as! UILabel
        elementLabel.text = elementDict[indexPath.item]["name"]
        meltingLabel.text = elementDict[indexPath.item]["melting"]
        boilingLabel.text = elementDict[indexPath.item]["boiling"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementDict.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .none
    }
    
    
}
