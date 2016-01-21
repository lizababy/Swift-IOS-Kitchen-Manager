//
//  GroceryCheckListViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 11/29/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse

class GroceryCheckListViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {

   
    @IBOutlet weak var checkListTableView: UITableView!
    
    var storeCheckListDict = [String : [String:Bool]]()
    let currentUser = PFUser.currentUser()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var notRegistered : Bool = false
    
    @IBAction func deleteHeaderSection(sender: UIButton) {
        let cell: UITableViewCell = sender.superview!.superview as! UITableViewCell
        let title = (cell.contentView.subviews.first as! UILabel).text!
        storeCheckListDict.removeValueForKey(title)
        saveCheckList()
        checkListTableView.reloadData()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        notRegistered = userDefaults.boolForKey("notRegistered")
        checkListTableView.setEditing(true, animated: true)

        checkListTableView.registerClass(CheckListTableViewCell.self, forCellReuseIdentifier: "cell")
         
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
        loadCheckList()
        
    }
    
    func emptyAlert(){
        let alertController = UIAlertController(title: "Checklist is empty!", message: "Do you want to load new items to checklist?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default){ _ in
            self.performSegueWithIdentifier("addSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func loadCheckList(){
        guard notRegistered else{
            
            readPF()
            return
        }
       if let resultDict =  DataHelper.sharedInstance.loadDictionaryFromFile("StoreCheckList.plist"){
            
            storeCheckListDict = resultDict as! [String : [String:Bool]]
            if storeCheckListDict.count == 0 {
                emptyAlert()
            }
        
        }

    }
    func readPF(){
        guard currentUser != nil else{
            return
        }
        let query:PFQuery = PFQuery.init(className: "StoreCheckList")
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            
            guard object != nil else {
                
                let StoreGroceryList = PFObject(className: "StoreCheckList")
                StoreGroceryList["storeCheckList"] = [String : [String:Bool]]() as NSDictionary
                StoreGroceryList["user"] = self.currentUser
                StoreGroceryList.saveInBackgroundWithTarget(self, selector: "readPF")
                
                return
            }
            self.storeCheckListDict = (object!["storeCheckList"] as? NSDictionary) as! [String : [String:Bool]]
            self.checkListTableView.reloadData()
            
            if self.storeCheckListDict.count == 0 {
                self.emptyAlert()
            }
            
        }
        
        
    }

    func updatePF(){
        
        guard currentUser != nil else{
            return
        }
        
        let query:PFQuery = PFQuery.init(className: "StoreCheckList")
        
        query.whereKey("user", equalTo: currentUser!)
        
        query.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
            guard object != nil else { return }
            object!["storeCheckList"] = self.storeCheckListDict as NSDictionary
            object!.saveInBackground()
        }
    }

    func saveCheckList() {
        guard notRegistered else{
            updatePF()
            return
        }
        
       DataHelper.sharedInstance.saveDictionaryToFile(storeCheckListDict as NSDictionary,fileName: "StoreCheckList.plist")
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        saveCheckList()

    }
    @IBAction func unwindToCheckList(segue:UIStoryboardSegue){
        saveCheckList()
        checkListTableView.reloadData()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = checkListTableView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        checkListTableView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        checkListTableView.contentInset.bottom = UIEdgeInsetsZero.bottom
        
    }
   
    // MARK: - TableViewCellDelegate methods
   
    
    func checkListItemDeleted(checkListItem: CheckListItem) {
        
        var checkListItems = storeCheckListDict[checkListItem.section]!
        checkListItems.removeValueForKey(checkListItem.text)
        storeCheckListDict[checkListItem.section] = checkListItems
        saveCheckList()
        checkListTableView.reloadData()
    }
    
    func checkListItemStriked(checkListItem: CheckListItem) {
        
        var checkListItems = storeCheckListDict[checkListItem.section]!
        checkListItems[checkListItem.text] = checkListItem.striked ? true : false
        storeCheckListDict[checkListItem.section] = checkListItems
        saveCheckList()
        
    }
    func checkListItemEdited(oldText : String?,checkListItem: CheckListItem) {
        
        var checkListItems = storeCheckListDict[checkListItem.section]!

        checkListItems.removeValueForKey(oldText!)
        checkListItems[checkListItem.text] = false
        storeCheckListDict[checkListItem.section] = checkListItems
        saveCheckList()
        checkListTableView.reloadData()

        
    }
    
    func cellDidBeginEditing(editingCell: CheckListTableViewCell) {
        
        let visibleCells = checkListTableView.visibleCells as! [CheckListTableViewCell]
        
        for cell in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                if cell !== editingCell {
                    cell.alpha = 0.5
                }
            })
        }
    }
    
    func cellDidEndEditing(editingCell: CheckListTableViewCell) {
        let visibleCells = checkListTableView.visibleCells as! [CheckListTableViewCell]
        for cell  in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                if cell !== editingCell {
                    cell.alpha = 1.0
                }
            })
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CheckListTableViewCell
            
            let titleforSection = storeCheckListDict.keys.sort()[indexPath.section]
            
            let checkListItems = storeCheckListDict[titleforSection]!
            
            let item = checkListItems.keys.sort()[indexPath.row]
            //cell.textLabel?.text = item.text
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            
            cell.checkListItem = CheckListItem(text: item, striked: checkListItems[item]!,section: titleforSection)
            cell.strikeCell(cell.checkListItem)
            cell.delegate = self

            return cell
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            cell.backgroundColor = UIColor(red: 0.96, green: 0.9, blue: 0.9, alpha: 1.0)
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
        if segue.identifier == "addSegue"{
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GroceryItemsViewController
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
            controller.navigationItem.leftBarButtonItem = cancelButton
        }
        if segue.identifier == "editSegue"{
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GroceryStoreViewController
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
            controller.navigationItem.leftBarButtonItem = cancelButton
            controller.storeCheckListDict = storeCheckListDict
        }
    }
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    


}
