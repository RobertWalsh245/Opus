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
    
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var lblGenreType: UILabel!
    @IBOutlet fileprivate var lblWelcome: UILabel!
    @IBOutlet var imgProfPic: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    var ViewOnly = true
    
    var venue: Venue! = Venue()
    
    var VIDForLoad: String = ""
    
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
         //Set tabbar venue property
        if let tbc = self.tabBarController as? VenueTabbar {
            tbc.venue = self.venue
        }
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
        
       // if let tbc = self.tabBarController as? VenueTabbar {
         //   self.venue = tbc.venue
        //}
        
        if self.VIDForLoad.isEmpty && self.venue.uid.isEmpty {
            //We weren't passed an ID or a venue object, load the current logged in user
            let UID = FIRAuth.auth()?.currentUser?.uid
            if  UID != nil {
                print("Log in found. Fetching data for UID ", "\(UID)")
                self.venue?.RetrieveVenueForUser(UID!)
            }else{
                //if No UID found in auth, push back to log in screen
                print("No Logged in UID found, returning to log in screen")
            }

        } else if !self.VIDForLoad.isEmpty {
            //We were passed a VID load that
            print("Loading venue from a passed in VID")
            self.venue?.RetrieveVenueForUser(VIDForLoad)
        } else if !self.venue.uid.isEmpty {
            //We were passed a venue object load that
            print("Venue object passed displaying data")
            self.DisplayUserInfo()
        }
        
        
        
    }
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        print("Edit pressed")
        performSegue(withIdentifier: "UserInfoFromVenue", sender: UIViewController.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
        if(segue.identifier == "UserInfoFromVenue") {
            let UserInfoVC = (segue.destination as! UserInfoViewController)
            UserInfoVC.venue = venue
        }
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
        
        //If the logged in user doesn't match the venue we are displaying then set to view only
        let UID = FIRAuth.auth()?.currentUser?.uid
        if UID != venue.uid {
            btnEdit.isHidden = true
        }else{
            btnEdit.isHidden = false
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
