//
//  ViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 11/25/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {
  
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var groceryButton: UIButton!
    
    @IBOutlet weak var foodPlannerButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        buttonView.layer.cornerRadius = 5
        
        groceryButton.layer.cornerRadius = 10
        groceryButton.layer.borderWidth = 2
        groceryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        foodPlannerButton.layer.cornerRadius = 10
        foodPlannerButton.layer.borderWidth = 2
        foodPlannerButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Restore the saved register info
        
        let notRegistered = userDefaults.boolForKey("notRegistered")
        if notRegistered {
            self.navigationItem.prompt = "You are not logged in!"
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LogIn", style: .Done, target: self, action: "loginAction:")
        }else{
            // Show the current visitor's username
            if let pUserName = PFUser.currentUser()?["username"] as? String {
                self.navigationItem.prompt = pUserName
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .Done, target: self, action: "logOutAction:")
                
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   override func viewWillAppear(animated: Bool) {
        //Restore the saved register info
        
        let notRegisterd = userDefaults.boolForKey("notRegistered")
        guard !notRegisterd else {
            return
        }
    
        if (PFUser.currentUser() == nil) {
           loginAction(self)
        }

    }
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
    }
    
    func loginAction(sender : AnyObject){
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func logOutAction(sender: AnyObject){
        
        // Send a request to log out a user
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGrocery"{
            
            //let controller = ((segue.destinationViewController as! UITabBarController).viewControllers![0] as! UINavigationController)
            //(segue.destinationViewController as! UINavigationController).topViewController as! GroceryCheckListTableViewController
           // controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showFoodPlanner" {
            
        }
    }
    

}

