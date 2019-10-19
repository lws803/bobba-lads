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
    var selectedElements : [Int: Dictionary<String, String>] = [:]
    
    override func viewDidLoad() {
        elementDict.append([
            "name":"element1",
            "melting": "7000",
            "boiling": "9000"
        ])
        elementDict.append([
            "name":"element2",
            "melting": "12",
            "boiling": "23"
        ])
        self.tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // call JJ's endpoint
        // process the json into dict by element name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let ARView = presentingViewController as? ViewController {
            ARView.selectedElements = self.selectedElements
            ARView.reload()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.accessoryType = .none
        
        let elementLabel : UILabel = cell.contentView.viewWithTag(1) as! UILabel
        let meltingLabel : UILabel = cell.contentView.viewWithTag(2) as! UILabel
        let boilingLabel : UILabel = cell.contentView.viewWithTag(3) as! UILabel
        elementLabel.text = "name: " + elementDict[indexPath.item]["name"]!
        meltingLabel.text = "melting point: " + elementDict[indexPath.item]["melting"]!
        boilingLabel.text = "boiling point: " + elementDict[indexPath.item]["boiling"]!
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
        selectedElements[indexPath.item] = elementDict[indexPath.item]
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .none
        selectedElements[indexPath.item] = nil
    }
    
    
    
}
