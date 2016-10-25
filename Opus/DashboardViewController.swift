//
//  DashboardViewController.swift
//  Opus
//
//  Created by Rob on 10/12/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded Dashboard view controller")
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    

    }
    
    @IBAction func btnNewArtistPressed(sender: UIButton) {
        print("New Artist Pressed")
        
        //Create new user object
        let UID = FIRAuth.auth()?.currentUser?.uid
        let newArtist =  Artist()
        newArtist.uid = UID!
        newArtist.CreateInDatabase()
    }
    @IBAction func btnLogoutPressed(sender: AnyObject) {
        print("Logout Pressed")
        //Push to log in view controller
        //let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        //self.navigationController!.pushViewController(secondViewController, animated: true)
        
        performSegueWithIdentifier("Logout", sender: UIViewController.self)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
