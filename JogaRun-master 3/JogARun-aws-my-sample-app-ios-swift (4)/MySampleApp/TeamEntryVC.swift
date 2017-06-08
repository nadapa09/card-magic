//
//  TeamEntryVC.swift
//  MySampleApp
//
//  Created by Labuser on 4/20/17.
//
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class TeamEntryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var noTeamsEnteredLabel: UILabel!
    @IBOutlet weak var teamList: UITableView!
    var teams: [Teams] = []
    var wait: Bool = true
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func addTeam(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "MakeTeam", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MakeTeam")
        navigationController?.pushViewController(controller, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        dbQuery()
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //dateLabel.text = logInfo[indexPath.row]._date!
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

//        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text =  String(describing: teams[indexPath.row]._team!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teams.count
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(teams[indexPath.row])
        let storyboard = UIStoryboard(name: "ViewTeam", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewTeam") as! ViewTeam
        controller.team = teams[indexPath.row]._team!
        navigationController?.pushViewController(controller, animated: true)

        
    }

    func dbQuery() {
        teams.removeAll()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#userId = :userId"
        scanExpression.expressionAttributeNames = ["#userId": "userId",]
        scanExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!,]
        wait = true
        objectMapper.scan(Teams.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for team in paginatedOutput.items as! [Teams] {
                    self.teams.append(team)
                }
                DispatchQueue.main.async {
                    self.teamList.reloadData()
                    if self.teams.count > 0 {
                        self.noTeamsEnteredLabel.text = ""
                    }
                    else {
                        self.noTeamsEnteredLabel.text = "You have no teams yet!"
                    }
                }
                
                self.wait = false
            }
            return nil
        })
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
