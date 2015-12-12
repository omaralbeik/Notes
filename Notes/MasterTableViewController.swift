//
//  MasterTableViewController.swift
//  Notes
//
//  Created by Omar Albeik on 12/12/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MasterTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var noteObjects: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() == nil {
            
            let loginViewController = PFLogInViewController()
            loginViewController.delegate = self
            
            let signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            self.presentViewController(loginViewController, animated: true, completion: nil)
            
        } else {
            
            self.fetchAllObjectsFromLocalDataStore()
            self.fetchAllObjects()
        }
    }
    
    func fetchAllObjectsFromLocalDataStore() {
        let query: PFQuery = PFQuery(className: "Note")
        query.fromLocalDatastore()
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self.noteObjects = temp.mutableCopy() as! NSMutableArray

                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func fetchAllObjects() {
        
        let query: PFQuery = PFQuery(className: "Note")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                PFUser.pinAllInBackground(objects)
                
                self.fetchAllObjectsFromLocalDataStore()
                
                
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if !username.isEmpty || !password.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("Failed to login")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        if let password = info["password"] as? String {
            return password.utf16.count >= 8
        } else {
            return false
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("user dismissed sign up")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noteObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! MasterTableViewCell
        
        let note = self.noteObjects.objectAtIndex(indexPath.row) as! PFObject
        cell.masterTitleLabel.text = note["title"] as? String
        cell.masterTextLabel.text = note["text"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("editNote", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editNote" {
            let addNoteViewController = segue.destinationViewController as! AddNoteTableViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            let note = self.noteObjects.objectAtIndex(indexPath.row)
            
            addNoteViewController.note = note as! PFObject
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
}
