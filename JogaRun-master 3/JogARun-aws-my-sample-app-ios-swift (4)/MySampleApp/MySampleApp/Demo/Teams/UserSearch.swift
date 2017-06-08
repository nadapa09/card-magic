//
//  UserSearch.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/15/17.
//
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB
import AWSMobileHubHelper

class UserSearch: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var theTable: UITableView!
    
    var myUsers = [Users]()
    var addUserToTeam = false
    var teamToAdd = ""
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    func getAllUsers() {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let scanExpression = AWSDynamoDBScanExpression()
        
        objectMapper.scan(Users.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
                self.myUsers = [Users]()
            } else if let paginatedOutput = task.result {
                self.myUsers = paginatedOutput.items as! [Users]
                DispatchQueue.main.async {
                    self.theTable.reloadData()
                }
            }
            return nil
        })
    }
    
    func getUsers() {
        
        let searchText = searchBar.text
        let searchLower = searchText?.lowercased()
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "begins_with(#username, :searchThis)"
        scanExpression.expressionAttributeNames = ["#username": "username",]
        
        scanExpression.expressionAttributeValues = [":searchThis": searchLower!,]
        
        objectMapper.scan(Users.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
                self.myUsers = [Users]()
            } else if let paginatedOutput = task.result {
                self.myUsers = paginatedOutput.items as! [Users]
                DispatchQueue.main.async {
                    self.theTable.reloadData()
                }
            }
            return nil
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        myCell.textLabel?.text = myUsers[indexPath.row]._username
        return myCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print(myUsers[indexPath.row])
        if(addUserToTeam){
            let alertController = UIAlertController(title: "Add user to " + self.teamToAdd + "?", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                let objectMapper = AWSDynamoDBObjectMapper.default()
                
                let itemToCreate: Teams = Teams()
                itemToCreate._team = self.teamToAdd
                itemToCreate._userId = self.myUsers[indexPath.row]._userId
                itemToCreate._username = self.myUsers[indexPath.row]._username
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
            
            
        }
        else {
            let storyboard = UIStoryboard(name: "ViewLog", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ViewLog") as! ViewLog
            if(myUsers[indexPath.row]._userId! != AWSIdentityManager.default().identityId!){
                controller.myLog = false
                controller.uId = myUsers[indexPath.row]._userId!
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        theTable.dataSource = self
        theTable.delegate = self
        navigationItem.rightBarButtonItem = homeButton
        navigationItem.rightBarButtonItem!.target = self
        navigationItem.rightBarButtonItem!.title = NSLocalizedString("Home", comment: "")
        navigationItem.rightBarButtonItem!.action = #selector(self.goBackHome)
        getAllUsers()
    }
    
    
    func goBackHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            getAllUsers()
        } else {
            getUsers()
        }
    }
    
}
