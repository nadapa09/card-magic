//
//  CreateLog.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/7/17.
//
//

import UIKit
import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class CreateLog:UIViewController {
    
    override func viewDidLoad() {
        insertData()
    }
    
    func insertData() {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemToCreate: Logs = Logs()
        
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._timestamp = NSNumber(value: Date().timeIntervalSince1970)
        itemToCreate._notes = "note-2"
        itemToCreate._shoe = ["shoe1":"AsicsJ33"]
        itemToCreate._distance = 3.0
        itemToCreate._time = 21
        itemToCreate._title = "Test Title"
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("AMAZON DynamoDB SAVE ERROR: \(error)")
                return
            }
            print("ITEM SAVED.")
        })
    }
}

//var _userId: String?
//var _timestamp: NSNumber?
//var _date: NSNumber?
//var _distance: NSNumber?
//var _notes: String?
//var _shoe: [String: String]?
//var _time: NSNumber?
//var _title: String?
