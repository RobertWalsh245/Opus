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
    
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnGigs: UIButton!
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
        nc.addObserver(self,
                       selector: #selector(self.PhotoRetrieved),
                       name: NSNotification.Name(rawValue: "PhotoRetrieved"),
                       object: nil)
        
        
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: .normal)
        
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBio.text = ""
        lblGenreType.text = ""
        lblWelcome.text = ""
        // Do any additional setup after loading the view, typically from a nib.
        //print("Loaded Venue Dashboard view controller")
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        //Set tabbar venue property
        if let tbc = self.tabBarController as? UserTabbar {
            tbc.venue = self.venue
            print("Tabbar venue object set")
        }

        
        //Determine what object we have if any
        if self.VIDForLoad.isEmpty && self.venue.uid.isEmpty {
            //We weren't passed an ID or a venue object, load the current logged in user
            let UID = FIRAuth.auth()?.currentUser?.uid
            if  UID != nil {
                print("Log in found. Fetching data for UID ", "\(UID)")
                //Hide tabbar to prevent user from moving to other tabs before venue is loaded
                self.tabBarController?.tabBar.isHidden = true
                self.venue?.RetrieveVenueForUser(UID!)
            }else{
                //if No UID found in auth, push back to log in screen
                print("No Logged in UID found, returning to log in screen")
            }

        } else if !self.VIDForLoad.isEmpty {
            //We were passed a VID load that
            print("Loading venue from a passed in VID")
            ActivityIndicator.startAnimating()
            self.venue?.RetrieveVenueForUser(VIDForLoad)
        } else if !self.venue.uid.isEmpty {
            //We were passed a venue object load that
            print("Venue object passed displaying data")
            self.DisplayUserInfo()
            self.DisplayPhoto()
        } else {
            lblWelcome.text = "Oops something went wrong"
            ActivityIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func btnGigsPressed(_ sender: UIButton) {
        
        let DestinationVC = self.storyboard!.instantiateViewController(withIdentifier: "VenueGigDashboard") as! VenueGigDashboardViewController
        DestinationVC.venue = self.venue
        
        self.navigationController?.pushViewController(DestinationVC, animated: true)
        
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
            self.tabBarController?.tabBar.isHidden = false
            //Set tabbar venue property
            if let tbc = self.tabBarController as? UserTabbar {
                tbc.venue = self.venue
                print("Tabbar venue object set")
            }

            if venue.photos.count > 0 {
                self.ActivityIndicator.startAnimating()
                venue.RetrievePhoto(venue.photos[0])
            }
            
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    
    func PhotoRetrieved(_ notification: Notification) {

        if notification.userInfo!["success"] != nil  {
            print("Photo retrieved successfully on VenueDashboard")
            DisplayPhoto()
        }else{
            //Something went wrong
            print("Something went wrong getting the photo")
        }
    }
    func DisplayPhoto() {
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
        self.imgProfPic.contentMode = .scaleAspectFill
        self.ActivityIndicator.stopAnimating()
        
        if venue._img != nil {
           self.imgProfPic.image = venue._img
        }else{
            //display default photo
        }
        
    }
    
    func DisplayUserInfo() {
        print("Displaying user data to view VenueDashboard")
        lblWelcome.text = "Venue: " + venue.name
        
        lblBio.lineBreakMode = .byWordWrapping
        lblBio.numberOfLines = 0
        lblBio.text = venue.bio
        
        //If the logged in user doesn't match the venue we are displaying then set to view only
        let UID = FIRAuth.auth()?.currentUser?.uid
        if UID != venue.uid {
            //Set up for a visitor to the profile
            btnEdit.isHidden = true
            btnGigs.isHidden = false
            btnLogout.isHidden = true
        }else{
            //Set up for the venues own profile
            btnEdit.isHidden = false
            btnGigs.isHidden = true
            btnLogout.isHidden = false
            //self.navigationController?.isNavigationBarHidden = false
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
    
    
    deinit {
        print("Deinit for VenueDashboard called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear for VenueDashboard called")
        //NotificationCenter.default.removeObserver(self)
        //Set tabbar venue property
        if let tbc = self.tabBarController as? UserTabbar {
            tbc.venue = self.venue
        }
        super.viewWillDisappear(animated)
    }
    
}
