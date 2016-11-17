//
//  VenueDashboardViewController.swift
//  Opus
//
//  Created by Rob on 11/3/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation



class VenueDashboardViewController: UIViewController {
    
    
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var lblGenreType: UILabel!
    @IBOutlet fileprivate var lblWelcome: UILabel!
    @IBOutlet var imgProfPic: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    var venue: Venue! = Venue()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.UserWasInit),
                       name: NSNotification.Name(rawValue: "UserInit"),
                       object: nil)
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: .normal)
        
        
    }
    deinit {
        print("Deinit for VenueDashboard called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear for VenueDashboard called")
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBio.text = ""
        lblGenreType.text = ""
        lblWelcome.text = ""
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded Venue Dashboard view controller")
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Do any additional setup after loading the view.
        
        let UID = FIRAuth.auth()?.currentUser?.uid
        if  UID != nil {
            print("Log in found. Fetching data for UID ", "\(UID)")
            self.venue?.RetrieveVenueForUser(UID!)
        }else{
            //if No UID found in auth, push back to log in screen
            print("No Logged in UID found, returning to log in screen")
        }
        
        
    }
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        print("Edit pressed")
        performSegue(withIdentifier: "UserInfo", sender: UIViewController.self)
    }
    
    
    @IBAction func btnLogoutPressed(_ sender: AnyObject) {
        print("Logout Pressed")
        //Push to log in view controller
        //let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        //self.navigationController!.pushViewController(secondViewController, animated: true)
        try! FIRAuth.auth()!.signOut()
        performSegue(withIdentifier: "Logout", sender: UIViewController.self)
    }
    
    func UserWasInit(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("User was initialized successfully on VenueDashboard")
            //The user was succesfully initalized, display the data to the user
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    
    func DisplayUserInfo() {
        print("Displaying user data to view VenueDashboard")
        lblWelcome.text = "Welcome " + venue.name + "!"
        
        lblBio.lineBreakMode = .byWordWrapping
        lblBio.numberOfLines = 0
        lblBio.text = venue.bio
        //withMaxSize: 25 * 1024 * 1024,
        if self.venue.photos.count > 0 {
            self.ActivityIndicator.startAnimating()
            FIRStorage.storage().reference(forURL: self.venue.photos[0]).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                let image = UIImage(data: data!)
                self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
                self.imgProfPic.contentMode = .scaleAspectFill
                self.ActivityIndicator.stopAnimating()
                self.imgProfPic.image = image
            })
        }
        
        
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
