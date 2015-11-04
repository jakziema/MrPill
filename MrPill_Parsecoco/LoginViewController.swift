//
//  MedicineViewController.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/8/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let tableViewWallSegue = "LoginSuccesfulTable"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser() {
            if user.isAuthenticated() {
                self.performSegueWithIdentifier(tableViewWallSegue, sender: nil)
            }
        }
        
    navigationController?.navigationBar.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        


    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Actions
    @IBAction func logInPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(userTextField.text!, password: passwordTextField.text!) { user,error in
            if user != nil {
                self.performSegueWithIdentifier(self.tableViewWallSegue, sender: nil)
            } else if let error = error {
                self.showErrorView(error)
            }
            
        }
    }
}
