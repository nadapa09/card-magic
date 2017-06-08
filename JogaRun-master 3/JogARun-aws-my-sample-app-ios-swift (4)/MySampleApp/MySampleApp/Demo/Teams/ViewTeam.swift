//
//  ViewTeam.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/21/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ViewTeam: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var teams: [Teams] = []
    var team: String = ""
    var wait: Bool = true
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamList: UITableView!
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNameLabel.text = team
        dbQuery()
        teamList.dataSource = self
        teamList.delegate = self
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = homeButton
        navigationItem.rightBarButtonItem!.target = self
        navigationItem.rightBarButtonItem!.title = NSLocalizedString("Home", comment: "")
        navigationItem.rightBarButtonItem!.action = #selector(self.goBackHome)
    }

func goBackHome() {
    navigationController?.popToRootViewController(animated: true)
}

    override func viewDidAppear(_ animated: Bool) {
        teamNameLabel.text = team
        dbQuery()
        teamList.dataSource = self
        teamList.delegate = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text =  String(describing: teams[indexPath.row]._username!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(teams[indexPath.row])
        let storyboard = UIStoryboard(name: "ViewLog", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewLog") as! ViewLog
        if(teams[indexPath.row]._userId! != AWSIdentityManager.default().identityId!){
            controller.myLog = false
            controller.uId = teams[indexPath.row]._userId!
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtindexPath: IndexPath){
        
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath){
        let alertController = UIAlertController(title: "Remove user from " + self.team + "?", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            let objectMapper = AWSDynamoDBObjectMapper.default()
            let item = Teams()
            item?._team = self.team
            item?._userId = self.teams[indexPath.row]._userId
 
            self.wait = true
            objectMapper.remove(item!, completionHandler: {(error: Error?) in
                                   DispatchQueue.main.async(execute: {
                                    
                                    })
                                })
            self.teams.remove(at: indexPath.row)
            tableView.reloadData()

        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
            // ...
        }
        return
    }
    
    func dbQuery() {
        teams.removeAll()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#team = :team"
        scanExpression.expressionAttributeNames = ["#team": "team",]
        scanExpression.expressionAttributeValues = [":team": self.team,]
        wait = true
        objectMapper.scan(Teams.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for team in paginatedOutput.items as! [Teams] {
                    self.teams.append(team)
                    DispatchQueue.main.async {
                        self.teamList.reloadData()
                        
                    }
                }
                self.wait = false
            }
            return nil
        })
    }
    @IBAction func addTeammates(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "UserSearch", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserSearch") as! UserSearch
        controller.addUserToTeam = true
        controller.teamToAdd = team
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
}
