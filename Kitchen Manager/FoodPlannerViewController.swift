//
//  FoodPlannerViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/10/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit

class FoodPlannerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView?

    var sectionHeader = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var indexHeader = ["Week1", "Week2", "Week3"]
    var backGroundColor = [ UIColor.redColor(), UIColor.brownColor(),UIColor.grayColor()]
    var cellDate = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "FoodPlanner"
        self.navigationItem.prompt = "Tap on Week or Date"
        let backItem = UIBarButtonItem(title: "Back", style: .Done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .Done, target: self, action: "today")
        let startDate = getStartDate()
        var nextDate = startDate
        for var i = 0 ; i < 21; i++ {
            
            // get the user's calendar
            let userCalendar = NSCalendar.currentCalendar()
            nextDate = userCalendar.dateByAddingUnit(
                [.Day],
                value: i,
                toDate: startDate,
                options: [])!
            cellDate.append(dateToString(nextDate))
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func today(){
        performSegueWithIdentifier("today", sender: self)
    }
    
    func dateToString(date : NSDate) -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter.stringFromDate(date)
        
    }
    func getCurrentDateIndex() -> Int {
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Weekday
        ]
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: NSDate())
        return dateTimeComponents.weekday
    }
    func getStartDate() -> NSDate {
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        let startDate = userCalendar.dateByAddingUnit(
            [.Day],
            value: -(getCurrentDateIndex() - 1),
            toDate: NSDate(),
            options: [])!
        return startDate
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionHeader.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexHeader.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell : UICollectionViewCell?
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
        (cell?.contentView.subviews.first as! UILabel).text = sectionHeader[indexPath.section]
        cell!.backgroundColor =  backGroundColor[indexPath.row]
        if (getCurrentDateIndex() == indexPath.section + 1) && indexPath.row == 0  {
            cell!.backgroundColor = UIColor.whiteColor()
        }
        cell!.layer.cornerRadius = 10
        cell!.layer.borderWidth = 2
        cell!.layer.borderColor = UIColor.blackColor().CGColor
        let fullDate = cellDate[7 * indexPath.row + indexPath.section]
        
        let fullDateArr = fullDate.componentsSeparatedByString(" ")
        let month = fullDateArr[0]
        let year = fullDateArr[2]
        let date = fullDateArr[1].componentsSeparatedByString(",")[0]
        
        (cell!.contentView.subviews[1] as! UILabel).text = date
        (cell!.contentView.subviews[2] as! UILabel).text = "\(month), \(year)"
        
        
        return cell!
    }
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionReusableView {
            
            if (kind == UICollectionElementKindSectionHeader) {
                let cell = collectionView.dequeueReusableSupplementaryViewOfKind(
                    kind, withReuseIdentifier: "header1",
                    forIndexPath: indexPath)
                if indexPath.section == 0 {
                    cell.subviews[0].hidden = false
                    cell.subviews[1].hidden = false
                    cell.subviews[2].hidden = false
                }else{
                    cell.subviews[0].hidden = true
                    cell.subviews[1].hidden = true
                    cell.subviews[2].hidden = true
                    
                }
                return cell
            }
            abort()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showWeekPlanner1"{
            // 0 t0 6
            (segue.destinationViewController as! FoodWeekTableViewController).dateHeader = Array(cellDate[0..<7])
            //(segue.destinationViewController as! FoodWeekTableViewController).week = "Week1"
        }
        if segue.identifier == "showWeekPlanner2"{
            //7 to 13
            (segue.destinationViewController as! FoodWeekTableViewController).dateHeader = Array(cellDate[7..<14])
            //(segue.destinationViewController as! FoodWeekTableViewController).week = "Week2"
        }
        if segue.identifier == "showWeekPlanner3"{
            //14 to 20
            (segue.destinationViewController as! FoodWeekTableViewController).dateHeader = Array(cellDate[14..<21])
           // (segue.destinationViewController as! FoodWeekTableViewController).week = "Week3"
        }
        if segue.identifier == "showDayPlanner"{
            if let indexPath = self.collectionView?.indexPathsForSelectedItems(){
                //selectedDate
                let selectedDate = "\(sectionHeader[indexPath.first!.section]), \(cellDate[ 7 * indexPath.first!.row + indexPath.first!.section])"
               // print(selectedDate)
               // print(indexHeader[indexPath.first!.row])

                (segue.destinationViewController as! FoodDayPlannerViewController).dateTitle = selectedDate
                //(segue.destinationViewController as! FoodDayPlannerViewController).week = indexHeader[indexPath.first!.row]

            }
        }
        if segue.identifier == "today"{
            (segue.destinationViewController as! FoodDayPlannerViewController).dateTitle = sectionHeader[getCurrentDateIndex()-1] + ", \(dateToString(NSDate()))"
            //(segue.destinationViewController as! FoodDayPlannerViewController).week = "Week1"
        }
    }


}
