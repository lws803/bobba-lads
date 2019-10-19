//
//  TriviaViewController.swift
//  NASA_Hackathon
//
//  Created by Ler Wilson on 19/10/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit
import Foundation


class TriviaViewController: UIViewController {
    @IBOutlet weak var triviaLabel: UILabel!
    @IBOutlet weak var solarEventLabel: UILabel!
    
    override func viewDidLoad() {
        triviaLabel.text = ""
        solarEventLabel.text = ""
    }
    

    override func viewDidAppear(_ animated: Bool) {
        // Call api here and display on label
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://nasa-server.herokuapp.com/external/v1/trivial/list")!
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            do {
                let serialized_data = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
                let isolatedData = serialized_data[Int.random(in: 0 ..< serialized_data.count)]
                self.triviaLabel.text = isolatedData["fact"] as? String
                
                let nasaEvent = isolatedData["nasa_event"] as! [String: Any]
                let solarEvent = nasaEvent["solarEvent"] as! [String: Any]
                self.solarEventLabel.text = "Solar event: " + (solarEvent["classType"] as! String)
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()

    }
    
}

