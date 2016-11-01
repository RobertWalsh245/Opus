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



class ArtistDashboardViewController: UIViewController {

    @IBOutlet fileprivate var lblWelcome: UILabel!
    @IBOutlet var ImgProfPic: UIImageView!
    
    var artist: Artist! = Artist()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.UserWasInit),
                       name: NSNotification.Name(rawValue: "UserInit"),
                       object: nil)
    }
    deinit {
        print("Deinit for ArtistDashboard called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear for ArtistDashboard called")
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded Artist Dashboard view controller")
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Do any additional setup after loading the view.
        
        let UID = FIRAuth.auth()?.currentUser?.uid
        if  UID != nil {
            print("Log in found. Fetching data for UID ", "\(UID)")
            self.artist?.RetrieveArtistForUser(UID!)
        }else{
            //if No UID found in auth, push back to log in screen
            print("No Logged in UID found, returning to log in screen")
        }


    }
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        print("Edit pressed")
        performSegue(withIdentifier: "UserInfo", sender: UIViewController.self)
    }
    
    @IBAction func btnNewArtistPressed(_ sender: UIButton) {
        print("New Artist Pressed")
        
        //Create new user object
        let UID = FIRAuth.auth()?.currentUser?.uid
        let newArtist =  Artist()
        newArtist.uid = UID!
        print(newArtist.uid)
        newArtist.CreateInDatabase()
    }
    @IBAction func btnLogoutPressed(_ sender: AnyObject) {
        print("Logout Pressed")
        //Push to log in view controller
        //let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        //self.navigationController!.pushViewController(secondViewController, animated: true)
        
        performSegue(withIdentifier: "Logout", sender: UIViewController.self)
    }
    
    func UserWasInit(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("User was initialized successfully on ArtistDashboard")
            //The user was succesfully initalized, display the data to the user
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    
    func DisplayUserInfo() {
        print("Displaying user data to view ArtistDashboard")
        lblWelcome.text = "Welcome " + artist.name
        
        if self.artist.photos.count > 0 {
            FIRStorage.storage().reference(forURL: self.artist.photos[0]).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                let image = UIImage(data: data!)
                self.ImgProfPic.image = image
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
