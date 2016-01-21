//
//  GroceryItemsViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/1/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse

class GroceryItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,UIPickerViewDataSource,UIPickerViewDelegate{
    
    var groceryDict = [String:[String:Bool]]()
    var pickerCategory = [String]()
    var selectedCategory : String?
    let currentUser = PFUser.currentUser()
    var notRegistered : Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var groceryCategoryPicker: UIPickerView!
    @IBOutlet weak var groceryTableView: UITableView!
    
    @IBAction func insertNewItem(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        guard pickerCategory.count > 0 else{
            return
        }
        alerViewWithTextFieldForItem("Add Grocery", message: "Add Grocery item", placeHolder: "Enter new item", indexPath:indexPath, action: "Add")
    }
    @IBAction func insertNewCategory(sender: AnyObject) {
        
        alerViewWithTextFieldForCategory("Add", message: "Add new Category", placeHolder: "Enter Category", action: "Add")
    }
    @IBAction func editCategory(sender: AnyObject) {
        guard pickerCategory.count > 0 else{
            return
        }
        alerViewWithTextFieldForCategory("Edit", message: "Edit Category", placeHolder: "Edit Category", action: "Edit")
    }
    @IBAction func uncheckAll(sender: AnyObject) {
        for (category, itemsForCategory) in groceryDict{
            
            for (item , checked ) in itemsForCategory{
                if checked{
                    groceryDict[category]![item] = false
                }
                itemsForCategory[item]
            }
        }
        groceryTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        notRegistered = userDefaults.boolForKey("notRegistered")
        loadData()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        saveData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func readPF(){
        guard currentUser != nil else{
            return
        }
        let query:PFQuery = PFQuery.init(className: "GroceryList")
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            
            guard object != nil else {
                let GroceryList = PFObject(className: "GroceryList")
                
                let query:PFQuery = PFQuery.init(className: "GeneralGrocery")
                query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
                    guard object != nil else { return}
                    // copy from Grocery to GroceryList
                    
                    GroceryList["groceryList"] = (object!["generalGrocery"] as? NSDictionary) as! [String:[String:Bool]]
                    GroceryList["user"] = self.currentUser
                    GroceryList.saveInBackgroundWithTarget(self, selector: "readPF")
                    
                    
                }
                return
            }
            self.groceryDict = (object!["groceryList"] as? NSDictionary) as! [String:[String:Bool]]
            let groceryCategory = self.groceryDict.keys
            self.pickerCategory = groceryCategory.sort()
            guard self.pickerCategory.count > 0 else{
                return
            }
            self.selectedCategory = self.pickerCategory[self.groceryCategoryPicker.selectedRowInComponent(0)]
            self.groceryCategoryPicker.reloadAllComponents()
            self.groceryTableView.reloadData()
            
        }
    }
    
    func updatePF(){
        
        guard currentUser != nil else{
        return
        }
        
        let query:PFQuery = PFQuery.init(className: "GroceryList")
        
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            guard object != nil else { return }
            object!["groceryList"] = self.groceryDict as NSDictionary
            object!.saveInBackground()
        }
    }

    
    func loadData(){
        guard notRegistered else{
            
            readPF()
            return
        }
       if let resultDict = DataHelper.sharedInstance.loadDictionaryFromResource("GroceryList",type: "plist"){
                
            groceryDict = resultDict as! [String :[String:Bool]]
            let groceryCategory = groceryDict.keys
            pickerCategory = groceryCategory.sort()
            guard pickerCategory.count > 0 else{
                return
            }
            selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        }
        
    }
    
    func saveData() {
        guard notRegistered else{
            
            updatePF()
            return
        }

        DataHelper.sharedInstance.saveDictionaryToFile(groceryDict as NSDictionary, fileName: "GroceryList.plist")
    }
    
    
    func alerViewWithTextFieldForCategory(title: String, message: String, placeHolder : String, action : String ){
        
        //let cell = groceryTableView.cellForRowAtIndexPath(indexPath)
        
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // Add the text field for user entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            
            textField.placeholder = placeHolder
            if action == "Edit"{
                textField.text = self.pickerCategory[self.groceryCategoryPicker.selectedRowInComponent(0)]
            }
            
        }
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler : nil)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
            
            if let editField = alertController.textFields?[0]{
                
                let newText = editField.text!.capitalizedString
                switch(action){
                case "Edit":
                    let selectedCategory = self.pickerCategory[self.groceryCategoryPicker.selectedRowInComponent(0)].capitalizedString
                    
                    if let index = self.pickerCategory.indexOf(selectedCategory){
                        
                        if self.groceryDict.indexForKey(selectedCategory) != nil {
                            
                            let savedDict =  self.groceryDict[selectedCategory]
                            self.groceryDict.removeValueForKey(selectedCategory)
                            self.groceryDict[newText] = savedDict
                            
                        }
                        self.pickerCategory[index] = newText
                    }
                    
                case "Add":
                    guard (self.pickerCategory.indexOf(newText) == nil) else{
                        return
                    }
                    
                    self.pickerCategory.append(newText)
                    
                    self.groceryDict[newText] = [:]
                    
                default :
                    
                    break
                }
                
                self.groceryCategoryPicker.reloadAllComponents()
            }
        }
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        if action == "Edit"{
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
                
                let selectedCategory = self.pickerCategory[self.groceryCategoryPicker.selectedRowInComponent(0)].capitalizedString
                
                if let index = self.pickerCategory.indexOf(selectedCategory){
                    
                    self.pickerCategory.removeAtIndex(index)
                    self.groceryDict.removeValueForKey(selectedCategory)
                    self.groceryCategoryPicker.reloadAllComponents()
                    self.groceryTableView.reloadData()
                }
            }
            alertController.addAction(deleteAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    func alerViewWithTextFieldForItem(title: String, message: String, placeHolder : String, indexPath : NSIndexPath, action : String ){
        
        let cell = groceryTableView.cellForRowAtIndexPath(indexPath)
        
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // Add the text field for user entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            
            textField.placeholder = placeHolder
            if action == "Edit"{
                textField.text = cell!.textLabel?.text
            }
            
        }
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler : nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
            if let editField = alertController.textFields?[0]{
                if var itemsDictForCategory = self.groceryDict[selectedCategory]{
                    switch(action){
                    case "Edit":
                        cell!.textLabel!.text = editField.text!
                        
                        let groceryItem = itemsDictForCategory.keys.sort()[indexPath.row]
                        let checked = itemsDictForCategory[groceryItem]!
                        
                        itemsDictForCategory.removeValueForKey(groceryItem)
                        itemsDictForCategory[editField.text!] = checked
                        
                    case "Add":
                        itemsDictForCategory[editField.text!] = false
                    default :
                        
                        break
                    }
                    
                    self.groceryDict[selectedCategory] = itemsDictForCategory
                    self.groceryTableView.reloadData()
                }
            }
        }
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
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
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //selectedCategory = pickerCategory[row]
        groceryTableView.reloadData()
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
        return 1
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("header")! as UITableViewCell
      //  headerCell.backgroundColor = UIColor.cyanColor()
        
        return headerCell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerCategory.count > 0 else{
            return 0
        }
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        guard let itemsDictForCategory = groceryDict[selectedCategory] else{
            return 0
        }
        return itemsDictForCategory.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        // Configure the cell...
        if let itemsDictForCategory = groceryDict[selectedCategory]{
            
            let groceryItem = itemsDictForCategory.keys.sort()[indexPath.row]
            
            let checked = itemsDictForCategory[groceryItem]!
            
            cell.textLabel!.text = groceryItem
            cell.accessoryType = checked ? .Checkmark : .None

        }else{
            cell.textLabel!.text = ""

        }
        
        return cell
    }
    
    // function to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
         // function to support editing the table view.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            self.alerViewWithTextFieldForItem("Edit Grocery", message: "Edit Grocery item", placeHolder: "Edit item", indexPath:indexPath, action: "Edit")
        })
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            if var itemsDictForCategory = self.groceryDict[selectedCategory]{
                
                let groceryItem = self.groceryTableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
                itemsDictForCategory.removeValueForKey(groceryItem!)
                
                self.groceryDict[selectedCategory] = itemsDictForCategory
                self.groceryTableView.reloadData()
            }
            
        })
        return [editAction,deleteAction]
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
       
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if var itemsDictForCategory = groceryDict[selectedCategory]{
                
                let groceryItem = self.groceryTableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
                
                itemsDictForCategory[groceryItem!] = false
                
                groceryDict[selectedCategory] = itemsDictForCategory
            }
            
            cell.accessoryType = .None
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard pickerCategory.count > 0 else{
            return
        }
        let selectedCategory = pickerCategory[groceryCategoryPicker.selectedRowInComponent(0)]
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if var itemsDictForCategory = groceryDict[selectedCategory]{
                
                let groceryItem = self.groceryTableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
                itemsDictForCategory[groceryItem!] = true
                
                groceryDict[selectedCategory] = itemsDictForCategory
            }
            cell.accessoryType = .Checkmark
            
        }
    }
    
    // Function to support rearranging the table view.
     func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
    }
    
    // Function to support conditional rearranging of the table view.
     func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "check" {
            let controller = segue.destinationViewController as! GroceryCheckListViewController
            var checkListItem = [String:Bool]()
            var update = false
            for (_, itemsForCategory) in groceryDict{
                
                for (item , checked ) in itemsForCategory{
                    if checked {
                       // controller.checkListItems[item] = false
                        checkListItem[item] = false
                        update = true
                    }
                }
            }
            if update {
                
                controller.storeCheckListDict["uncategorized"] = checkListItem
            }
            

        }
        
    }
    

}
