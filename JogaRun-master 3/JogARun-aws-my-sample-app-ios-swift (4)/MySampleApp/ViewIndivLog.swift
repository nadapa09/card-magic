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
        //dateLabel.text = logInfo[indexPath.row]._date!
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!CustomTableCell
        cell.miles.text = "Miles: " + String(describing: logInfo.logStuff[indexPath.row]._distance!)
        cell.title.text = "Title: " + String(describing: logInfo.logStuff[indexPath.row]._title!)
        cell.time.text = "Time: " + String(describing: logInfo.logStuff[indexPath.row]._time!)
        cell.shoe.text = "Shoe: " + String(describing: logInfo.logStuff[indexPath.row]._shoe!)
        cell.note.text = String(describing: logInfo.logStuff[indexPath.row]._notes!)
        cell.pace.text = "Pace: " + calculatePace(time: logInfo.logStuff[indexPath.row]._time as! Double, miles: logInfo.logStuff[indexPath.row]._distance as! Double)
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
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath){
        if tableView.cellForRow(at: indexPath)?.editingStyle == UITableViewCellEditingStyle.delete{
            let alertController = UIAlertController(title: "Remove log?", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                let objectMapper = AWSDynamoDBObjectMapper.default()
                let item = Logs()
                item?._userId = self.logInfo.logStuff[indexPath.row]._userId
                item?._timestamp = self.logInfo.logStuff[indexPath.row]._timestamp
                
                let shoeToDelete = Shoes()
                let cell = tableView.cellForRow(at: indexPath) as! CustomTableCell
                let shoe = cell.shoe.text
                var array = shoe?.components(separatedBy: "\n")
                let result = array?[0]
                
                array = result?.components(separatedBy: ": ")
                let result2 = array?[1]
                
                print("RESULT: \(result2!)")
                shoeToDelete?._userId = AWSIdentityManager.default().identityId!
                shoeToDelete?._shoe = result2!
                
                let queryExpression = AWSDynamoDBQueryExpression()
                queryExpression.keyConditionExpression = "#userId = :userId"
                queryExpression.expressionAttributeNames = ["#userId": "userId"]
                queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!]
                
                objectMapper.query(Shoes.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                    
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let paginatedOutput = task.result {
                        let shoeMileage = paginatedOutput.items as! [Shoes]
                        for aShoe in shoeMileage {
                            print("SHOES SHOES SHOES: \(aShoe._shoe!) == \(result2!)")
                            if (aShoe._shoe! == result2!) {
                                let actualMileage = aShoe._mileage
                                
                                let milesText = cell.miles.text!
                                var array = milesText.components(separatedBy: ": ")
                                let milesMiles = array[1]
                                let newMileage = NSNumber(value: Double(actualMileage!) - Double(milesMiles)!)
                                shoeToDelete?._mileage = newMileage
                                
                                objectMapper.remove(shoeToDelete!, completionHandler: {(error: Error?) in
                                    if let error = error {
                                        print("The request failed. Error: \(error)")
                                    } else {
                                        shoeToDelete?._mileage = newMileage
                                        objectMapper.save(shoeToDelete!, completionHandler: {(error: Error?) -> Void in
                                            if let error = error {
                                                print("Amazon DynamoDB Save Error: \(error)")
                                                return
                                            }
                                            print("Shoe saved.")
                                        })
                                    }
                                })
                            }
                        }
                    }
                    return nil
                })
                
                
                objectMapper.remove(item!, completionHandler: {(error: Error?) in
                    DispatchQueue.main.async(execute: {
                        
                    })
                })
                self.logInfo.logStuff.remove(at: indexPath.row)
                tableView.reloadData()
                
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
                // ...
            }
            return
        }
    }
    
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
    }
}

class LogHolder {
    var logStuff: [Logs] = []
}
