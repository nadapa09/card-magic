//
//  ViewIndivLog.swift
//  MySampleApp
//
//  Created by Matt Hibshman on 4/11/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class ViewIndivLog: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var logInfo: LogHolder = LogHolder()
    @IBOutlet weak var dateLabel: UILabel!
    var dateString: String = ""
    var myLog = true
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    @IBOutlet weak var createButton: UIButton!
    override func viewDidLoad() {
        if(!myLog){
            createButton.isEnabled = false
        }
        navigationItem.rightBarButtonItem = homeButton
        navigationItem.rightBarButtonItem!.target = self
        navigationItem.rightBarButtonItem!.title = NSLocalizedString("Home", comment: "")
        navigationItem.rightBarButtonItem!.action = #selector(self.goBackHome)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func goBackHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateLabel.text = dateString
        tableView.dataSource = self
        tableView.delegate = self
        print(logInfo)
        tableView.reloadData()
    }
    
    @IBAction func addLog(_ sender: UIButton) {
        let loginStoryboard = UIStoryboard(name: "CreateLog", bundle: nil)
        let loginController = loginStoryboard.instantiateViewController(withIdentifier: "CreateLog") as! CreateLog
        loginController.logInfo = logInfo.logStuff
        loginController.add = true
        loginController.dateString = self.dateString
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dateLabel.text = String(describing: logInfo.logStuff[indexPath.row]._date!)
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!CustomTableCell
        cell.meetingPlace.text =  "Meeting Place: " + String(describing: logInfo.logStuff[indexPath.row]._meetingPlace!)
        cell.location.text = "Location: " + String(describing: logInfo.logStuff[indexPath.row]._location!)
        cell.availability.text = "Availability: " + String(describing: logInfo.logStuff[indexPath.row]._remainingCapacity!)
        cell.startTime.text = "Start Time: " + String(describing: logInfo.logStuff[indexPath.row]._startTime!)
        cell.endTime.text = "End Time: " + String(describing: logInfo.logStuff[indexPath.row]._endTime!)
        cell.role.text = "Role: " + String(describing: logInfo.logStuff[indexPath.row]._role!)
        cell.notes.text = String(describing: logInfo.logStuff[indexPath.row]._description!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return logInfo.logStuff.count
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if myLog {
            return .delete
        }
        
        return .none
    }
    
//    func tableView(_ tableView: UITableView,
//                   commit editingStyle: UITableViewCellEditingStyle,
//                   forRowAt indexPath: IndexPath){
//        if tableView.cellForRow(at: indexPath)?.editingStyle == UITableViewCellEditingStyle.delete{
//            let alertController = UIAlertController(title: "Remove log?", message: "", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
//                // ...
//            }
//            alertController.addAction(cancelAction)
//            
//            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
//                let objectMapper = AWSDynamoDBObjectMapper.default()
//                let item = Logs()
//               // item?._userId = self.logInfo.logStuff[indexPath.row]._userId
//                item?._timestamp = self.logInfo.logStuff[indexPath.row]._timestamp
//                
//                let shoeToDelete = Shoes()
//                let cell = tableView.cellForRow(at: indexPath) as! CustomTableCell
//                let shoe = cell.shoe.text
//                var array = shoe?.components(separatedBy: "\n")
//                let result = array?[0]
//                
//                array = result?.components(separatedBy: ": ")
//                let result2 = array?[1]
//                
//                print("RESULT: \(result2!)")
//                shoeToDelete?._userId = AWSIdentityManager.default().identityId!
//                shoeToDelete?._shoe = result2!
//                
//                let queryExpression = AWSDynamoDBQueryExpression()
//                queryExpression.keyConditionExpression = "#userId = :userId"
//                queryExpression.expressionAttributeNames = ["#userId": "userId"]
//                queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!]
//                
//                objectMapper.query(Shoes.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
//                    
//                    if let error = task.error as? NSError {
//                        print("The request failed. Error: \(error)")
//                    } else if let paginatedOutput = task.result {
//                        let shoeMileage = paginatedOutput.items as! [Shoes]
//                        for aShoe in shoeMileage {
//                            print("SHOES SHOES SHOES: \(aShoe._shoe!) == \(result2!)")
//                            if (aShoe._shoe! == result2!) {
//                                let actualMileage = aShoe._mileage
//                                
//                                let milesText = cell.miles.text!
//                                var array = milesText.components(separatedBy: ": ")
//                                let milesMiles = array[1]
//                                let newMileage = NSNumber(value: Double(actualMileage!) - Double(milesMiles)!)
//                                shoeToDelete?._mileage = newMileage
//                                
//                                objectMapper.remove(shoeToDelete!, completionHandler: {(error: Error?) in
//                                    if let error = error {
//                                        print("The request failed. Error: \(error)")
//                                    } else {
//                                        shoeToDelete?._mileage = newMileage
//                                        objectMapper.save(shoeToDelete!, completionHandler: {(error: Error?) -> Void in
//                                            if let error = error {
//                                                print("Amazon DynamoDB Save Error: \(error)")
//                                                return
//                                            }
//                                            print("Shoe saved.")
//                                        })
//                                    }
//                                })
//                            }
//                        }
//                    }
//                    return nil
//                })
//                
//                
//                objectMapper.remove(item!, completionHandler: {(error: Error?) in
//                    DispatchQueue.main.async(execute: {
//                        
//                    })
//                })
//                self.logInfo.logStuff.remove(at: indexPath.row)
//                tableView.reloadData()
//                
//            }
//            alertController.addAction(OKAction)
//            self.present(alertController, animated: true) {
//                // ...
//            }
//            return
//        }
//    }
    
    func calculatePace(time: Double, miles: Double) -> String {
        let times = time
        print(time)
        let dist = miles
        print(miles)
        
        
        var sec = times - Double(Int(times))
        print(sec)
        sec = (times-sec)*60 + sec*100
        
        print(sec)
        sec = sec/dist
        print(sec)
        sec = sec/60
        print(sec)
        var ans = sec - Double(Int(sec))
        ans = sec-ans + ans*60/100
        
        ans = round(100*ans)/100
        var ansString = String(ans).replacingOccurrences(of: ".", with: ":")
        if ansString.characters.count == 3{
            ansString += "0"
        }
        return ansString
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if(self.logInfo.logStuff[indexPath.row]._remainingCapacity == 0){
            return
        }
        let alertController = UIAlertController(title: "Sign up for this shadow?", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            let objectMapper = AWSDynamoDBObjectMapper.default()
            let item = Events()
            item?._location = self.logInfo.logStuff[indexPath.row]._location
            item?._timestamp = self.logInfo.logStuff[indexPath.row]._timestamp
            
            objectMapper.remove(item!, completionHandler: {(error: Error?) in
                DispatchQueue.main.async(execute: {
                    
                })
            })
            
            
            
            let itemToCreate: Events = Events()
            
            
            
            
            
            //        if(date.text?.characters.count == 9 || date.text?.characters.count == 8){
            //            date.text = "0" + date.text!
            //        }
            itemToCreate._location = self.logInfo.logStuff[indexPath.row]._location
            itemToCreate._date = self.logInfo.logStuff[indexPath.row]._date
            itemToCreate._description = self.logInfo.logStuff[indexPath.row]._description
            itemToCreate._endTime = self.logInfo.logStuff[indexPath.row]._endTime
            itemToCreate._meetingPlace = self.logInfo.logStuff[indexPath.row]._meetingPlace
            itemToCreate._name = self.logInfo.logStuff[indexPath.row]._name
            var cap = self.logInfo.logStuff[indexPath.row]._remainingCapacity as! Double
            itemToCreate._remainingCapacity = (cap-1) as NSNumber?
            self.logInfo.logStuff[indexPath.row]._remainingCapacity = (cap-1) as NSNumber?
            itemToCreate._role = self.logInfo.logStuff[indexPath.row]._role
            itemToCreate._startTime = self.logInfo.logStuff[indexPath.row]._startTime
            itemToCreate._timestamp = NSNumber(value: Date().timeIntervalSince1970)
            
            
            self.tableView.reloadData()
            
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                }
                print("Item saved.")
                
            })
            
            
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
            // ...
        }
        return

        
    }
    
}

class LogHolder {
    var logStuff: [Events] = []
}
