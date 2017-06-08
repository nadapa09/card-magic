//
//  ViewLog.swift
//  MySampleApp
//
//  Created by Thomas Gales on 4/7/17.
//
//

import UIKit
import Foundation
import AWSMobileHubHelper
import AWSDynamoDB

class ViewLog: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var calendar: UICollectionView!
    @IBOutlet weak var month: UILabel!
    
    var calendarObj = Calendar.current
    var dC: DateComponents = DateComponents()
    var currentMonth: Int = 0
    var currentYear: Int = 0
    var firstDay: Int = 0
    var refDate: Date = Date()
    var leapYear: Int = 28
    var workoutsArray: [Logs] = []
    var monthArray: [[Logs]] = []
    var wait: Bool = true
    var milesArray: [Double] = Array(repeating: 0, count: 32)
    var timeArray: [Double] = Array(repeating: 0, count: 32)
    var uId = AWSIdentityManager.default().identityId!
    var myLog = true
    fileprivate let homeButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    override func viewDidLoad(){
        currentMonth = calendarObj.component(.month, from: Date())
        currentYear = calendarObj.component(.year, from: refDate)
        dC = DateComponents(year: currentYear,month: currentMonth)
        navigationItem.rightBarButtonItem = homeButton
        navigationItem.rightBarButtonItem!.target = self
        navigationItem.rightBarButtonItem!.title = NSLocalizedString("Home", comment: "")
        navigationItem.rightBarButtonItem!.action = #selector(self.goBackHome)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calendar.dataSource = self
        calendar.delegate = self
        
        dC = DateComponents(year: currentYear,month: currentMonth)
        let start = Calendar.current.date(from: dC)!
        firstDay = calendarObj.component(.weekday, from: start)
        
        //Stupid February leap year rules
        if(currentYear%4 == 0){
            if (currentYear%100 == 0) {
                leapYear = 29
            }
            else if (currentYear%400 == 0){
                leapYear = 28
            }
            else {
                leapYear = 29
            }
        }
        
        setMonth()
        loadData()
        displayData()
        displayMiles()
        calendar.reloadData()
    }
    
    func goBackHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "ViewSegue" && (sender as! CustomCollectionCell).number == -1)
        {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
         if (segue.identifier == "ViewSegue") {
            let num = (sender as! CustomCollectionCell).number
            print("CELL NUMBER: " + String(num))
            let indivView = segue.destination as! ViewIndivLog
            indivView.dateString = String(currentMonth) + "/" + String(num) + "/" + String(currentYear)
            indivView.logInfo.logStuff = monthArray[num]
            indivView.myLog = self.myLog
        }
        
    }
    
    func checkLeapYearRules() {
        if(currentYear%4 == 0){
            if (currentYear%100 == 0) {
                leapYear = 29
            }
            else if (currentYear%400 == 0){
                leapYear = 28
            }
            else {
                leapYear = 29
            }
        }
    }
    
    @IBAction func prevMonth(_ sender: UIButton) {
        currentMonth -= 1
        if(currentMonth == 0){
            currentMonth = 12
            currentYear -= 1
            checkLeapYearRules()
        }
        refDate = refDate.addingTimeInterval(-2339200)
        dC = DateComponents(year: currentYear,month: currentMonth)
        let start = Calendar.current.date(from: dC)!
        print(start)
        firstDay = calendarObj.component(.weekday, from: start)
        print(firstDay)
        setMonth()
        displayData()
        displayMiles()
        calendar.reloadData()
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        currentMonth += 1
        if(currentMonth == 13){
            currentMonth = 1
            currentYear += 1
            checkLeapYearRules()
        }
        refDate = refDate.addingTimeInterval(2339200)
        dC = DateComponents(year: currentYear,month: currentMonth)
        let start = Calendar.current.date(from: dC)!
        firstDay = calendarObj.component(.weekday, from: start)
        setMonth()
        displayData()
        displayMiles()
        calendar.reloadData()
    }
    
    func setMonth() {
        monthArray.removeAll()
        for _ in 0..<32{
            let logArray = [Logs]()
            monthArray.append(logArray)
        }
        milesArray = Array(repeating: 0, count: 32)
        timeArray = Array(repeating: 0, count: 32)
        switch currentMonth{
        case 1:
            month.text = "January " + String(currentYear)
        case 2:
            month.text = "February " + String(currentYear)
        case 3:
            month.text = "March " + String(currentYear)
        case 4:
            month.text = "April " + String(currentYear)
        case 5:
            month.text = "May " + String(currentYear)
        case 6:
            month.text = "June " + String(currentYear)
        case 7:
            month.text = "July " + String(currentYear)
        case 8:
            month.text = "August " + String(currentYear)
        case 9:
            month.text = "September " + String(currentYear)
        case 10:
            month.text = "October " + String(currentYear)
        case 11:
            month.text = "November " + String(currentYear)
        case 12:
            month.text = "December " + String(currentYear)
        default:
            break
        }
    }
    
    func thirtyDays() -> Bool{
        if(currentMonth == 4 || currentMonth == 6 || currentMonth == 9 || currentMonth == 11){
            return true
        }
        return false
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: CustomCollectionCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionCell
        
        if(indexPath.section == 0 && indexPath.row+1 < firstDay){
            cell.label.text = ""
            cell.timeLabel.text = ""
            cell.milesLabel.text = ""
            cell.miles.text = ""
            cell.time.text = ""
            cell.backgroundColor = #colorLiteral(red: 0.9562007785, green: 0.6269171834, blue: 0.3377318978, alpha: 0.7497844828)
            cell.alpha = 0.75
            cell.number = -1
            return cell
        }
        if(((indexPath.section)*7+indexPath.row+1) - firstDay+1 > leapYear && currentMonth == 2){
            cell.label.text = ""
            cell.timeLabel.text = ""
            cell.milesLabel.text = ""
            cell.miles.text = ""
            cell.time.text = ""
            cell.backgroundColor = #colorLiteral(red: 0.9562007785, green: 0.6269171834, blue: 0.3377318978, alpha: 0.7497844828)
            cell.alpha = 0.75
            cell.number = -1
            return cell
        }
        if(((indexPath.section)*7+indexPath.row+1) - firstDay+1 > 30 && thirtyDays()){
            cell.label.text = ""
            cell.timeLabel.text = ""
            cell.milesLabel.text = ""
            cell.miles.text = ""
            cell.time.text = ""
            cell.backgroundColor = #colorLiteral(red: 0.9562007785, green: 0.6269171834, blue: 0.3377318978, alpha: 0.7497844828)
            cell.alpha = 0.75
            cell.number = -1
            return cell
        }
        if(((indexPath.section)*7+indexPath.row+1) - firstDay+1 > 31){
            cell.label.text = ""
            cell.timeLabel.text = ""
            cell.milesLabel.text = ""
            cell.miles.text = ""
            cell.time.text = ""
            cell.backgroundColor = #colorLiteral(red: 0.9562007785, green: 0.6269171834, blue: 0.3377318978, alpha: 0.7497844828)
            cell.alpha = 0.75
            cell.number = -1
            return cell
        }
        cell.number = (((indexPath.section)*7+indexPath.row+1) - firstDay+1)
        let miles = milesArray[(((indexPath.section)*7+indexPath.row+1) - firstDay+1)]
        let time = timeArray[(((indexPath.section)*7+indexPath.row+1) - firstDay+1)]
        if (miles == 0 && time == 0){
            cell.label.text = String(((indexPath.section)*7+indexPath.row+1) - firstDay+1)

            cell.timeLabel.text = ""
            cell.milesLabel.text = ""
            cell.miles.text = ""
            cell.time.text = ""
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else{
            cell.timeLabel.text = "Time:"
            cell.milesLabel.text = "Miles:"
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.label.text = String(((indexPath.section)*7+indexPath.row+1) - firstDay+1)
            cell.miles.text = String(milesArray[(((indexPath.section)*7+indexPath.row+1) - firstDay+1)])
            cell.time.text = String(timeArray[(((indexPath.section)*7+indexPath.row+1) - firstDay+1)])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath){
        let cellTouched = indexPath.section + indexPath.row
        print(cellTouched)
    }
    
    @IBAction func dataRequested(_ sender: UIButton) {
        loadData()
    }
    
    func loadData() {
        workoutsArray.removeAll()
        let objectMapper = AWSDynamoDBObjectMapper.default()
                
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": uId,]
        wait = true
        objectMapper.query(Logs.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for log in paginatedOutput.items as! [Logs] {
                    self.workoutsArray.append(log)
                    print(log)
                }
                
                self.wait = false
            }
            return nil
        })
        
    }
    
    func displayData() {
        
        while(wait){
            
        }
        wait = false
        for log in workoutsArray {
            print("HEYYYYYYYY\n")
            print(log)
            if(log._date == nil){
                continue
            }
            var index = log._date?.index((log._date?.startIndex)!, offsetBy: 6)
            if(log._date?.characters.count == 9){
                print("CHARACTERS?????? " + log._date!)
                index = log._date?.index((log._date?.startIndex)!, offsetBy: 5)
            }
            let workoutYear = Int((log._date?.substring(from: index!))!)
            print("WORKOUT YEAR: " + String(describing: workoutYear))
            if workoutYear != currentYear{
                continue
            }
            index = log._date?.index((log._date?.startIndex)!, offsetBy: 2)
            let workoutMonth = Int((log._date?.substring(to: index!))!)
            if workoutMonth != currentMonth{
                continue
            }
            print("LOG DATE " + log._date!)
            index = log._date?.index((log._date?.startIndex)!, offsetBy: 3)
            let indexEnd = log._date?.index((log._date?.endIndex)!, offsetBy: -5)
            
            let range = index!..<indexEnd!
            let workoutDay = Int((log._date?.substring(with: range))!)
            print("WORKOUT DAY: " + String(describing: workoutDay))
            if(monthArray.count <= workoutDay!){
                return
            }
            monthArray[workoutDay!].append(log)
            
            
        }
        print(monthArray)
    }
    
    func displayMiles() {
        var i = 0
        for log in monthArray{
            if log.isEmpty{
                i += 1
                continue
            }
            for l in log{
                let dist = Double(l._distance!)
                let time = Double(l._time!)
                milesArray[i] += dist
                timeArray[i] += time
            }
            i += 1
        }
        
    }
    
    
    
    
    
    
}
