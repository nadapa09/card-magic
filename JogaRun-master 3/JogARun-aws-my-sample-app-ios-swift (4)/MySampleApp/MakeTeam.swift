//
//  MakeTeam.swift
//  MySampleApp
//
//  Created by Labuser on 4/20/17.
//
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCognitoIdentityProvider


class MakeTeam: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {

    
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentTeamTable: UITableView!
    
    var usersToAdd: [String] = []     //ulimately i think these should be user ID's instead of usernames but
    var myUsers = [Users]()
    var currentMembers = [Users]()
    var update: Bool = false
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTable.dataSource = self
        usersTable.delegate = self
        searchBar.delegate = self
        currentTeamTable.dataSource = self
        currentTeamTable.delegate = self
        getAllUsers()
        navigationItem.rightBarButtonItem = homeButton
        navigationItem.rightBarButtonItem!.target = self
        navigationItem.rightBarButtonItem!.title = NSLocalizedString("Home", comment: "")
        navigationItem.rightBarButtonItem!.action = #selector(self.goBackHome)
    }
    
func goBackHome() {
    navigationController?.popToRootViewController(animated: true)
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            getAllUsers()
        } else {
            getUsers()
        }
    }
    
    //User clicked Create! team
    @IBAction func submit(_ sender: UIButton) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemToCreate: Teams = Teams()
        itemToCreate._team = self.teamName.text
        
        for member in currentMembers {
            itemToCreate._userId = member._userId
            itemToCreate._username = member._username
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                }
                print("Item saved.")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
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
                    self.usersTable.reloadData()
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
                    self.usersTable.reloadData()
                }
            }
            return nil
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.usersTable {
            return myUsers.count
        } else if tableView == self.currentTeamTable {
            return currentMembers.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if tableView == self.usersTable {
            myCell.textLabel?.text = myUsers[indexPath.row]._username
        } else if tableView == self.currentTeamTable {
            myCell.textLabel?.text = currentMembers[indexPath.row]._username
        }
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.usersTable {
            if (!usersToAdd.contains(myUsers[indexPath.row]._userId!)) {
                usersToAdd.append(String(describing: myUsers[indexPath.row]._userId))
            }
            if (!currentMembers.contains(myUsers[indexPath.row])) {
                currentMembers.append(myUsers[indexPath.row])
            }
        } else if tableView == self.currentTeamTable {
            usersToAdd.remove(at: indexPath.row)
            currentMembers.remove(at: indexPath.row)
        }
        currentTeamTable.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
