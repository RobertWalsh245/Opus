//
//  UserSettingsViewController.swift
//  Opus
//
//  Created by Rob on 10/10/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsViewController: UIViewController {
    
    //Outlets
    
    @IBOutlet private var txtUsername: UITextField!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var lblError: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}

}