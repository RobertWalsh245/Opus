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

    
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var lblGenreType: UILabel!
    @IBOutlet fileprivate var lblWelcome: UILabel!
    @IBOutlet var imgProfPic: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    var artist: Artist! = Artist()
    
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
        
        if artist.uid.isEmpty {
            //We don't have an artist object, go get it
            let UID = FIRAuth.auth()?.currentUser?.uid
            if  UID != nil {
                print("Log in found. Fetching data for UID ", "\(UID)")
                self.artist?.RetrieveArtistForUser(UID!)
            }else{
                //if No UID found in auth, push back to log in screen
                print("No Logged in UID found, returning to log in screen")
            }
        } else {
            //We already have the artist object, display it
            self.DisplayUserInfo()
            self.DisplayPhoto()
        }
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lblBio.text = ""
        lblGenreType.text = ""
        lblWelcome.text = ""
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded Artist Dashboard view controller")
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Do any additional setup after loading the view.
        
        //Set tabbar artist property
        if let tbc = self.tabBarController as? UserTabbar {
            tbc.artist = self.artist
        }


    }
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        print("Edit pressed")
        performSegue(withIdentifier: "UserInfoFromArtist", sender: UIViewController.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
        if(segue.identifier == "UserInfoFromArtist") {
            let UserInfoVC = (segue.destination as! UserInfoViewController)
            UserInfoVC.artist = artist
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
            print("User was initialized successfully on ArtistDashboard")
            //The user was succesfully initalized, display the data to the user
            //Set tabbar shared artist object
            if let tbc = self.tabBarController as? UserTabbar {
                tbc.artist = self.artist
            }
            
            //Call to retrieve the photo for the artist
            
            if artist.photos.count > 0 && artist._img == nil {
                self.ActivityIndicator.startAnimating()
                artist.RetrievePhoto(artist.photos[0])
            }
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    
    func PhotoRetrieved(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("Photo retrieved successfully on ArtistDashboard")
            self.DisplayPhoto()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }

    
    func DisplayUserInfo() {
        print("Displaying user data to view ArtistDashboard")
        lblWelcome.text = "Welcome " + artist.name + "!"
        lblGenreType.text = artist.genre + " " + artist.type
        lblBio.lineBreakMode = .byWordWrapping
        lblBio.numberOfLines = 0
        lblBio.text = artist.bio
        
        
        //withMaxSize: 25 * 1024 * 1024,
       // if self.artist.photos.count > 0 {
         //   self.ActivityIndicator.startAnimating()
         //   FIRStorage.storage().reference(forURL: self.artist.photos[0]).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
         //       let image = UIImage(data: data!)
         //       self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
         //       self.imgProfPic.contentMode = .scaleAspectFill
         //       self.ActivityIndicator.stopAnimating()
          //      self.imgProfPic.image = image
         //   })
       // }

        
    }
    func DisplayPhoto() {
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
        self.imgProfPic.contentMode = .scaleAspectFill
        self.ActivityIndicator.stopAnimating()
        
        if artist._img != nil {
            self.imgProfPic.image = artist._img
        }else{
            //display default photo
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear for ArtistDashboard called")
        //NotificationCenter.default.removeObserver(self)
        //Set tabbar artist property
        if let tbc = self.tabBarController as? UserTabbar {
            tbc.artist = self.artist
        }
        super.viewWillDisappear(animated)
    }
    deinit {
        print("Deinit for ArtistDashboard called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
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
