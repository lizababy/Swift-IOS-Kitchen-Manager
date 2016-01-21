//
//  GroceryStoreViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/12/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse


class GroceryStoreViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    var pickerCategory = [String]()
    var selectedCategory : String?
    var checkListDict = [String:Bool]()
    var storeCheckListDict = [String : [String:Bool]]()
    let currentUser = PFUser.currentUser()
    var notRegistered : Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()

    //var sectionTitles = [String]()
    @IBAction func deleteHeaderSection(sender: UIButton) {
        let cell: UITableViewCell = sender.superview!.superview as! UITableViewCell
        let title = (cell.contentView.subviews.first as! UILabel).text!
        storeCheckListDict.removeValueForKey(title)
        checkListTableView.reloadData()
    }
    @IBOutlet weak var checkListTableView: UITableView!
    
    
    @IBOutlet weak var storePickerView: UIPickerView!
    
    @IBAction func insertNewCategory(sender: AnyObject) {
        
        alerViewWithTextFieldForCategory("Add", message: "Add new Category", placeHolder: "Enter Category", action: "Add")
    }
    @IBAction func editCategory(sender: AnyObject) {
        
        guard pickerCategory.count > 0 else {
            return
        }
        alerViewWithTextFieldForCategory("Edit", message: "Edit Category", placeHolder: "Edit Category", action: "Edit")
    }
    @IBAction func insertSection(sender: AnyObject) {
        guard pickerCategory.count > 0 else {
            return
        }
        let selectedCategory = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)]
        
        guard (storeCheckListDict.keys.sort().indexOf(selectedCategory.capitalizedString) == nil) else{
            return
        }
        
        storeCheckListDict[selectedCategory.capitalizedString] = [:]
        checkListTableView.reloadData()
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        notRegistered = userDefaults.boolForKey("notRegistered")
        checkListTableView.setEditing(true, animated: true)
        loadStore()
        //loadCheckList()
    }
    func loadStore(){
        guard notRegistered else {
            
            readPFStore()
            return
        }
        
       if let resultArray = DataHelper.sharedInstance.loadArrayFromResource("GroceryStore",type: "plist"){
            
            pickerCategory = resultArray as! [String]
            if pickerCategory.count > 0{
                selectedCategory = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)]
                
            }
        }
        
        
    }
    func saveStore() {
        guard notRegistered else{
            updatePFStore()
            return
        }
        DataHelper.sharedInstance.saveArrayToFile(pickerCategory as NSArray, fileName: "GroceryStore.plist")
        
    }
    
    func readPFStore(){
        guard currentUser != nil else{
            return
        }
        let query:PFQuery = PFQuery.init(className: "GroceryStore")
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            
            guard object != nil else {
                let GroceryStore = PFObject(className: "GroceryStore")
                
                let query:PFQuery = PFQuery.init(className: "GeneralStore")
                query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
                    guard object != nil else { return}
                    // copy from Grocery to GroceryList
                    
                    GroceryStore["groceryStore"] = (object!["generalStore"] as? NSArray) as! [String]
                    GroceryStore["user"] = self.currentUser
                    GroceryStore.saveInBackgroundWithTarget(self, selector: "readPFStore")
                    
                    
                }
                return
            }
            
            self.pickerCategory = object!["groceryStore"] as! [String]
            if self.pickerCategory.count > 0{
                self.selectedCategory = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)]
            }
            self.storePickerView.reloadAllComponents()
            self.checkListTableView.reloadData()
            
        }
    }
    
    func updatePFStore(){
        
        guard currentUser != nil else{
            return
        }
        
        let query:PFQuery = PFQuery.init(className: "GroceryStore")
        
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            guard object != nil else { return }
            object!["groceryStore"] = self.pickerCategory as NSArray
            object!.saveInBackground()
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alerViewWithTextFieldForCategory(title: String, message: String, placeHolder : String, action : String ){
        
       
        //let cell = groceryTableView.cellForRowAtIndexPath(indexPath)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // Add the text field for user entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            
            textField.placeholder = placeHolder
            if action == "Edit"{
                //textField.text = self.selectedCategory
                textField.text = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)]
            }
            
        }
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler : nil)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
            
            if let editField = alertController.textFields?[0]{
                
                let newText = editField.text!.capitalizedString
                switch(action){
                    
                case "Edit":
                    
                    let selectedCategory = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)].capitalizedString
                    
                    if let index = self.pickerCategory.indexOf(selectedCategory){
                        
                        if self.storeCheckListDict.indexForKey(selectedCategory) != nil {
                            
                            let savedDict =  self.storeCheckListDict[selectedCategory]
                            self.storeCheckListDict.removeValueForKey(selectedCategory)
                            self.storeCheckListDict[newText] = savedDict
                            
                        }
                        self.pickerCategory[index] = newText
                    }
                    
                case "Add":
                    
                    guard (self.pickerCategory.indexOf(newText) == nil) else{
                        return
                    }
                    
                    self.pickerCategory.append(newText)
                    
                default :
                    
                    break
                }
                self.saveStore()
                self.storePickerView.reloadAllComponents()
                self.checkListTableView.reloadData()
                
            }
        }
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        if action == "Edit"{
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
                
                let selectedCategory = self.pickerCategory[self.storePickerView.selectedRowInComponent(0)].capitalizedString
                
                if let index = self.pickerCategory.indexOf(selectedCategory){
                    
                    self.pickerCategory.removeAtIndex(index)
                    self.storeCheckListDict.removeValueForKey(selectedCategory)
                    self.saveStore()
                    self.storePickerView.reloadAllComponents()
                    self.checkListTableView.reloadData()
                }
            }
            alertController.addAction(deleteAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    //MARK: - Picker View Delegates and data sources
    //MARK: Picker View Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCategory.count
    }
    
    //MARK: Picker View Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCategory[row].capitalizedString
    }
    
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = pickerCategory[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
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
        return storeCheckListDict.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let titleforSection = storeCheckListDict.keys.sort()[section]
        return (storeCheckListDict[titleforSection]?.count)!
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  sectionHeaderCell = tableView.dequeueReusableCellWithIdentifier("header")! as UITableViewCell
        sectionHeaderCell.contentView.layer.borderColor = UIColor.grayColor().CGColor
        sectionHeaderCell.contentView.layer.borderWidth = 2
        sectionHeaderCell.contentView.layer.cornerRadius = 5
        
        
        (sectionHeaderCell.contentView.subviews.first as! UILabel).text = storeCheckListDict.keys.sort()[section]
        return sectionHeaderCell
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let titleforSection = storeCheckListDict.keys.sort()[indexPath.section]
        let groceryItemDict = storeCheckListDict[titleforSection]!
        
        cell.textLabel!.text = groceryItemDict.keys.sort()[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
   
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let titleforFromSection = storeCheckListDict.keys.sort()[sourceIndexPath.section]
        let titleforToSection = storeCheckListDict.keys.sort()[destinationIndexPath.section]
        
        let itemMoved:String = (storeCheckListDict[titleforFromSection]?.keys.sort()[sourceIndexPath.row])!
            
        let striked = storeCheckListDict[titleforFromSection]![itemMoved]!
        storeCheckListDict[titleforFromSection]?.removeValueForKey(itemMoved)
        storeCheckListDict[titleforToSection]?[itemMoved] = striked
        
        
    }
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "edit" {
            
            let controller = segue.destinationViewController as! GroceryCheckListViewController
                saveStore()
                controller.storeCheckListDict = storeCheckListDict
            
        }

    }
    

}
