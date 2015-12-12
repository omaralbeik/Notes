//
//  AddNoteTableViewController.swift
//  Notes
//
//  Created by Omar Albeik on 12/12/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import Parse

class AddNoteTableViewController: UITableViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    var note: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if note != nil {
            self.titleField.text = note["title"] as? String
            self.textView.text = note["text"] as? String
        } else {
            self.note = PFObject(className: "Note")
        }
    }
    
    @IBAction func saveNoteBarButtonItemTapped(sender: UIBarButtonItem) {
        
        self.note["username"] = PFUser.currentUser()!.username!
        self.note["title"] = self.titleField.text!
        self.note["text"] = self.textView.text!
        self.note.saveEventually { (success, error) -> Void in
            
            if error == nil {
                
            } else {
                print(error?.localizedDescription)
            }
            
            self.navigationController?.popViewControllerAnimated(true)

        }
    }
    
    
}
