//
//  NewUserViewController.swift
//  Opus
//
//  Created by Rob on 10/10/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class NewUserViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {


    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtBio: UITextView!
    @IBOutlet var btnLocationServices: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var imgProfPic: UIImageView!
 

    @IBOutlet var txtDOB: UITextField!
    
    let picker = UIImagePickerController()
    
    var currentUser: User?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.InitialFormatting()
        
        
        picker.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        txtBio.delegate = self
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Subscribe to observe the notification that that the user was Initialized
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self,
                       selector: #selector(self.UserWasInit),
                       name: "UserInit",
                       object: nil)
        
        print("Loaded NewUserViewController")
        //Do any additional setup after loading the view.
        print("Checking for a logged in UID")
        let UID = FIRAuth.auth()?.currentUser?.uid
        if  UID != nil {
            print("Log in found. Fetching data for UID ", "\(UID)")
            //Create new user class by passing logged in userID to user class to retrieve
            self.currentUser = User(UID: UID!)
            //From here User class should post notification of successful init, caught below
        }else{
            //if No UID found in auth, push back to log in screen
            print("No Logged in UID found, returning to log in screen")
        }
    }
    
//Outlets
    @IBAction func btnLocationServicesPressed(sender: UIButton) {
        print("Location Services Pressed")
        //locationManager.requestAlwaysAuthorization()
        currentUser?.toDict()
    }

    @IBAction func btnNextPressed(sender: UIButton) {
        print("Next Pressed")
        currentUser?.UpdateInDatabase()
        performSegueWithIdentifier("Dashboard", sender: UIViewController.self)
    }
    @IBAction func txtDOBBeganEditing(sender: UITextView) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        //Set maximum date to be someone who is 16 years old and no one older than 100
        datePickerView.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -16, toDate: NSDate(), options: [])
        datePickerView.minimumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -100, toDate: NSDate(), options: [])
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    @IBAction func txtNameEditingEnded(sender: UITextField) {
        print("Name did end editing")
        self.currentUser!.name = txtName.text!
        //print(self.currentUser!.name)
        currentUser?.UpdateInDatabase()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("Bio did end editing");
        self.currentUser!.bio = txtBio.text
        //print(self.currentUser!.bio)
        currentUser?.UpdateInDatabase()
    }
    
    @IBAction func btnUploadProfPicPressed(sender: UIButton) {
        print("Upload Profile Picture pressed")
        
        //Check if user already has 3 photos
        if currentUser?.photos.count == currentUser!._PhotoLimit  {
            print("User has uploaded the maximum amount of photos")
        }else{
            picker.allowsEditing = false
            picker.sourceType = .PhotoLibrary
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
//Functions
    func UserWasInit(notification: NSNotification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("User was initialized successfully")
            //The user was succesfully initalized, display the data to the user
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            print("Something went wrong with initializing the user")
        }
    }
    


    func DisplayUserInfo() {
        //Display whatever data is available
        print("Displaying User info to view")
        txtName.text = self.currentUser?.name
        txtBio.text = self.currentUser?.name
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Format image
        //self.imgProfPic.contentMode = .ScaleAspectFit
        //self.imgProfPic.layer.borderWidth = 1
        //self.imgProfPic.layer.masksToBounds = false
        //self.imgProfPic.layer.borderColor = UIColor.blackColor().CGColor
        //self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.height/2
        
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
        self.imgProfPic.contentMode = .ScaleAspectFill

        self.imgProfPic.image = image
        currentUser?.SavePhoto(image)
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        currentUser?.lat = locValue.latitude
        currentUser?.lon = locValue.longitude
        //print("Updated user location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            // If status has not yet been determied, ask for authorization
            print("Requesting always location auth")
            manager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            // If authorized when in use
            print("Starting location updates")
            manager.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            // If always authorized
            print("Starting location updates")
            manager.startUpdatingLocation()
            break
        case .Restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            print("Location restricted e.g. parental controls, nothing user can do")
            break
        case .Denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            print("User has denied location services, must go to settings to enable")
            break
        default:
            break
        }
    }
    
    func InitialFormatting() {
        //Called at view load
        
        //Border bio box
        self.txtBio.layer.borderWidth = 1
        self.txtBio.layer.borderColor = UIColor.blackColor().CGColor
        self.txtBio.layer.cornerRadius = 10.0
        //Make profile pic rounded
        self.imgProfPic.layer.borderWidth = 1
        self.imgProfPic.layer.masksToBounds = false
        self.imgProfPic.layer.borderColor = UIColor.blackColor().CGColor
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.height/2
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.width/2
        self.imgProfPic.clipsToBounds = true
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
    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        self.txtDOB.text = strDate
    }

    @IBAction func txtDOBEditingDidEnd(sender: AnyObject) {
        self.currentUser?.dob = txtDOB.text!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
