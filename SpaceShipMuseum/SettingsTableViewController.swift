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
        self.tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // call JJ's endpoint
        // process the json into dict by element name
        // https://nasa-server.herokuapp.com/external/v1/compounds/get
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://nasa-server.herokuapp.com/external/v1/compounds/get")!
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            do {
                let serialized_data = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
                
                print(serialized_data)
                self.elementDict = []
                for item in serialized_data {
                    let compoundName = item["name"] as! String
                    let melting = Double(String(item["melting_point"] as! NSString))! + 273
                    let boiling = Double(String(item["boiling_point"] as! NSString))! + 273
                    

                    self.elementDict.append([
                        "name": compoundName,
                        "melting": String(format: "%.0f", melting),
                        "boiling": String(format: "%.0f", boiling)
                    ])
                }
                self.tableView.reloadData()
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
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
