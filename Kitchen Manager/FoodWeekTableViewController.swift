//
//  FoodWeekTableViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/10/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse

class FoodWeekTableViewController: UITableViewController {

    var header = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var subHead = ["Breakfast", "Lunch", "Evening", "Dinner"]
    var dateHeader : [String]?
    var week : String?
    var foodPlanForWeek = [String:[String:[String]]]()
    let currentUser = PFUser.currentUser()
    var notRegistered : Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notRegistered = userDefaults.boolForKey("notRegistered")
        let backItem = UIBarButtonItem(title: "Back", style: .Done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.prompt = "Add food Menu for this week"
        for (i,date) in (dateHeader?.enumerate())! {
            dateHeader![i] = "\(header[i]), \(date)"

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       loadFoodPlan()
       // self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadFoodPlan(){
        guard notRegistered else{
            readPFFoodPlan()
            return
        }
        
        if let resultDict =  DataHelper.sharedInstance.loadDictionaryFromFile("FoodPlanDate.plist"){
            
            copyData(resultDict as! [String : [String : [String]]])
        }
        
    }
    func copyData(resultDict : [String:[String:[String]]]){
        let foodPlanForDate = resultDict
        for (i,date) in (dateHeader?.enumerate())!{
            if let foodPlan =  foodPlanForDate[date]{
                self.foodPlanForWeek[self.header[i]] = foodPlan
            }else{
                self.foodPlanForWeek[self.header[i]] = [:]
                for category in self.subHead{
                    self.foodPlanForWeek[self.header[i]]![category] = []
                }
            }
            
        }
        
        self.tableView.reloadData()
    }
    func readPFFoodPlan() {
        guard currentUser != nil else{
            return
        }
        let query:PFQuery = PFQuery.init(className: "FoodPlanDate")
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            
           
            guard object != nil else {
                let FoodPlan = PFObject(className: "FoodPlanDate")
                let foodPlanForDate = [String:[String:[String]]]()
                
                FoodPlan["foodPlanDate"] = foodPlanForDate as NSDictionary
                FoodPlan["user"] = self.currentUser
                FoodPlan.saveInBackgroundWithTarget(self, selector: "readPFFoodPlan")
                return
            }
            let FoodPlan = PFObject(className: "FoodPlanDate")
            FoodPlan["user"] = self.currentUser
            let foodPlanForDate = (object!["foodPlanDate"] as? NSDictionary)
            self.copyData(foodPlanForDate as! [String : [String : [String]]])
            
        }
        
        
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return header.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subHead.count
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  sectionHeaderCell = tableView.dequeueReusableCellWithIdentifier("header")! as UITableViewCell
        (sectionHeaderCell.contentView.subviews.first as! UILabel).text = dateHeader![section]
        return sectionHeaderCell
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("content", forIndexPath: indexPath)
        
        
        (cell.contentView.subviews[0] as! UILabel).text = (subHead[indexPath.row] as NSString).substringToIndex(1)
        let sectionTitle = header[indexPath.section]
        let indexTitle = subHead[indexPath.row]
        
        guard let foodPlan = foodPlanForWeek[sectionTitle] else{
            return cell
        }
        guard let menuArray = foodPlan[indexTitle] else{
            return cell
        }
        let menus = menuArray.joinWithSeparator(", ")
        (cell.contentView.subviews[1] as! UILabel).text = menus

        // Configure the cell...

        return cell
    }
  
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "dayPlanner" {
            let cell: UITableViewCell = sender!.superview!!.superview as! UITableViewCell
            
           (segue.destinationViewController as! FoodDayPlannerViewController).dateTitle = (cell.contentView.subviews.first as! UILabel).text!
            
        }
        
    }
    

}
