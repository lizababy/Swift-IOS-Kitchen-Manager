//
//  LoginViewController.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 11/25/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit

import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField){
        
        if textField == self.userNameField {
            passwordField.becomeFirstResponder()
        }else{
            passwordField.resignFirstResponder()
        }
        
    }
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue){
    }
    
    @IBAction func notRegisteredUser(sender :AnyObject){
        /*Save the user not registered infornation*/
        userDefaults.setBool(true, forKey: "notRegistered")
        
        
    }
    
    
    @IBAction func LoginAction(sender: AnyObject) {
        let username = self.userNameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username!.characters.count < 5 {
            let alertController = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler : nil)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        } else if password!.characters.count < 4 {
            
            let alertController = UIAlertController(title: "Invalid", message: "Password must be greater than 4 characters", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler : nil)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    
                    
                    let alertController = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel){ _ in
                        self.userDefaults.setBool(false, forKey: "notRegistered")
                        
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                } else {
                    let errormessage = error!.userInfo["error"] as! NSString
                    
                    let alertController = UIAlertController(title: "Error", message: "\(errormessage)", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler : nil)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
