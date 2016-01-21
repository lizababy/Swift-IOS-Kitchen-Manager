//
//  FoodDayPlannerViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/9/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse


class FoodDayPlannerViewController: UIViewController {
    
    var pickerCategory = ["Breakfast", "Lunch", "Evening", "Dinner"]
    var selectedCategory : String?
    var week : String?
    
    
    var foodPlanForDate = [String:[String:[String]]]()
    var foodPlanForCategory = [String:[String]]()
    var foodMenuForMeal = [String]()
    let currentUser = PFUser.currentUser()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var notRegistered : Bool = false

    var dateTitle : String?
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var dayPlannerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notRegistered = userDefaults.boolForKey("notRegistered")
        
        if let date = dateTitle{
            self.navigationItem.title = date
            self.navigationItem.prompt = "Pick type and add/edit/delete menu"
        }
        
        selectedCategory = pickerCategory[0]
        
        //load plan for day
        loadFoodPlan()
        
        let addButton = UIButton(type: .ContactAdd)
        addButton.addTarget(self, action: "AddTextField:", forControlEvents: .TouchUpInside)
        dayPlannerTableView.tableHeaderView = addButton
        // Do any additional setup after loading the view.
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        saveFoodPlan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func AddTextField(sender: UIButton) {
        dayPlannerTableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if foodPlanForCategory[selectedCategory!] == nil{
            foodPlanForCategory[selectedCategory!] = []
        }
        foodPlanForCategory[selectedCategory!]!.insert("", atIndex: 0)
        dayPlannerTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        dayPlannerTableView.endUpdates()
        let cell = dayPlannerTableView.cellForRowAtIndexPath(indexPath)!
        (cell.contentView.subviews[0] as! UITextField ).becomeFirstResponder()

    }
    
    @IBAction func removeTextField(sender: UIButton) {
        
        let cell: UITableViewCell = sender.superview!.superview as! UITableViewCell
        let indexpath = dayPlannerTableView.indexPathForCell(cell)!
        dayPlannerTableView.beginUpdates()
        foodPlanForCategory[selectedCategory!]!.removeAtIndex(indexpath.row)
        dayPlannerTableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .Automatic)
        
        dayPlannerTableView.endUpdates()
    }
    func loadFoodPlan(){
        guard notRegistered else{
            readPFFoodPlan()
            return
        }
        if let resultDict =  DataHelper.sharedInstance.loadDictionaryFromFile("FoodPlanDate.plist"){
            
            //foodPlanForWeek = resultDict as! [String : [String:[String:[String]]]]
            foodPlanForDate = resultDict as! [String:[String:[String]]]
            
            if let foodPlan =  foodPlanForDate[self.dateTitle!]{
                foodPlanForCategory = foodPlan
                
            }else{
                foodPlanForCategory = [:]
            }

        }
        
        
    }
    
    func saveFoodPlan() {
        
        foodPlanForDate[dateTitle!] = foodPlanForCategory
        
        guard notRegistered else{
            updatePFFoodPlan()
            return
        }
       DataHelper.sharedInstance.saveDictionaryToFile(foodPlanForDate as NSDictionary,fileName: "FoodPlanDate.plist")
        
    }
    func readPFFoodPlan(){
        
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
            
            self.foodPlanForDate = (object!["foodPlanDate"] as? NSDictionary) as! [String:[String:[String]]]
            //self.foodPlanForDay = self.foodPlanForWeek[self.week!]!
            if let foodPlan =  self.foodPlanForDate[self.dateTitle!]{
                self.foodPlanForCategory = foodPlan

            }else{
                self.foodPlanForCategory = [:]
            }
            self.dayPlannerTableView.reloadData()
            
        }
        
        
    }
    
    func updatePFFoodPlan(){
        
        guard currentUser != nil else{
            return
        }
        
        let query:PFQuery = PFQuery.init(className: "FoodPlanDate")
        
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            guard object != nil else { return }
            object!["foodPlanDate"] = self.foodPlanForDate as NSDictionary
            object!.saveInBackground()
        }
    }

    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = dayPlannerTableView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        dayPlannerTableView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        dayPlannerTableView.contentInset.bottom = UIEdgeInsetsZero.bottom
        
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        return false
    }
    func textFieldDidEndEditing(textField: UITextField) {
        let cell: UITableViewCell = textField.superview!.superview as! UITableViewCell
        if let indexPath =  dayPlannerTableView.indexPathForCell(cell){
            let row = indexPath.row
            foodPlanForCategory[selectedCategory!]![row] = textField.text!
        }
        
    }
    
    //MARK: - Picker View Delegates and data sources
    //MARK: Picker View Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    //MARK: Picker View Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCategory[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = pickerCategory[row]
        dayPlannerTableView.reloadData()
    }
   
    /* better memory management version */
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(pickerCategory.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = pickerCategory[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .Center
        
        return pickerLabel
        
    }
   
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
   
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let foodMenus = foodPlanForCategory[selectedCategory!] else{
            return 0
        }
        return  foodMenus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if let foodPlan = foodPlanForCategory[selectedCategory!]{
            (cell.contentView.subviews[0] as! UITextField ).text = foodPlan[indexPath.row]
        }else{
            foodPlanForCategory[pickerCategory[indexPath.row]] = []
        }
        
        return cell
    }

   
}
