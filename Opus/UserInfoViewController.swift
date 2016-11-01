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
//SHould be one entry view that updates based on whether you are a vendor or artist otherwise alot of duplicated code

class UserInfoViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {


    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtBio: UITextView!
    @IBOutlet var btnLocationServices: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var imgProfPic: UIImageView!
 
//Artist Outlets
    @IBOutlet var ArtistDetailView: UIView!
    @IBOutlet var txtDOB: UITextField!
    @IBOutlet var txtGender: UITextField!
    @IBOutlet var txtGenre: UITextField!
    @IBOutlet var txtArtistType: UITextField!
    
//Venue Outlets
    @IBOutlet var VenueDetailView: UIView!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var txtCapacity: UITextField!
    
    var _Ref = FIRDatabase.database().reference()
    
    let picker = UIImagePickerController()
    var lat: Double! = 0.0
    var lon: Double! = 0.0
    
    var artist: Artist! = Artist()
    var venue: Venue! = Venue()
    var userType: String = ""
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Subscribe to observe the notification that that the user was Initialized
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.ArtistWasInit),
                       name: NSNotification.Name(rawValue: "ArtistInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.VenueWasInit),
                       name: NSNotification.Name(rawValue: "VenueInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.UserWasInit),
                       name: NSNotification.Name(rawValue: "UserInit"),
                       object: nil)
    }
    deinit {
        print("Deinit for UserInfo called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear called for UserInfo")
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded UserInfoViewController")
        
        picker.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        txtBio.delegate = self
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        
        //Do any additional setup after loading the view.
        let UID = FIRAuth.auth()?.currentUser?.uid
        if  UID != nil {
            print("Log in found. Fetching data for UID ", "\(UID)")
            
            //Attempt to fetch user from both venue and artist tree. Succesful notification will kick of the remaining neccesary load ing
            self.artist.RetrieveArtistForUser(UID!)
            self.venue.RetrieveVenueForUser(UID!)
            
        }else{
            //if No UID found in auth, push back to log in screen
            print("No Logged in UID found, returning to log in screen")
        }
    }
    
//Outlets
    @IBAction func btnLocationServicesPressed(_ sender: UIButton) {
        print("Location Services Pressed")
        //locationManager.requestAlwaysAuthorization()
        //currentUser?.toDict()
    }

    @IBAction func btnNextPressed(_ sender: UIButton) {
        print("Next Pressed")
        self.Save()
        performSegue(withIdentifier: "Dashboard", sender: UIViewController.self)
    }
    @IBAction func txtDOBBeganEditing(_ sender: UITextView) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        //Set maximum date to be someone who is 16 years old and no one older than 100
        datePickerView.maximumDate = (Calendar.current as NSCalendar).date(byAdding: .year, value: -16, to: Date(), options: [])
        datePickerView.minimumDate = (Calendar.current as NSCalendar).date(byAdding: .year, value: -100, to: Date(), options: [])
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerChanged), for: UIControlEvents.valueChanged)
    }
    @IBAction func txtEditingEnded(_ sender: UITextField) {
        print("Textbox did end editing")
        self.Save()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Bio did end editing");
        self.Save()
    }
//Photo
    @IBAction func btnUploadProfPicPressed(_ sender: UIButton) {
        print("Upload Profile Picture pressed")
        
        //Check if user already has 3 photos
        //if currentUser?.photos.count == currentUser!._PhotoLimit  {
         //   print("User has uploaded the maximum amount of photos")
        //}else{
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        //}
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Format image
        //self.imgProfPic.contentMode = .ScaleAspectFit
        //self.imgProfPic.layer.borderWidth = 1
        //self.imgProfPic.layer.masksToBounds = false
        //self.imgProfPic.layer.borderColor = UIColor.blackColor().CGColor
        //self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.height/2
        
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.size.width / 2
        self.imgProfPic.contentMode = .scaleAspectFill
        
        self.imgProfPic.image = image
        print("Saving photo")
        if (self.userType == "artist"){
            artist.SavePhoto(image)
        }else{
            venue.SavePhoto(image)
        }

        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//Functions
    func ArtistWasInit(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            //print("Artist was initialized successfully on UserInfoVC")
            //The user was succesfully initalized, display the data to the user
            self.userType = "artist"
            self.InitialFormatting()
           // self.DisplayUserInfo()
        }else{
            //Something went wrong
           // print("Something went wrong with initializing the user")
        }
    }
    func VenueWasInit(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            //print("Venue was initialized successfully on UserInfoVC")
            //The user was succesfully initalized, display the data to the user
            self.userType = "venue"
            self.InitialFormatting()
            //self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    func UserWasInit(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("User was initialized successfully on UserInfoVC")
            //The user was succesfully initalized, display the data to the user
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }

    
    //SHould be single property of artist or venue
    func Save() {
        //Called whenever editing on text box ends
        if (self.userType == "artist"){
            print("Attempting to save artist info to database from UserInfoVC")
            //It's an artist, grab the data from the view and save it to the DB
            artist.name = txtName.text!
            artist.bio = txtBio.text!
            artist.dob = txtDOB.text!
            artist.gender = txtGender.text!
            artist.genre = txtGenre.text!
            artist.type = txtArtistType.text!
            artist.lat = self.lat
            artist.lon = self.lon
            artist.UpdateInDatabase()
            
        }else{
            print("Attempting to save venue info to database from UserInfoVC")
            //It's a venue, grab the data from the view and save it to the DB
            venue.name = txtName.text!
            venue.bio = txtBio.text!
            venue.address = txtAddress.text!
            venue.capacity = Int(txtCapacity.text!)!
            venue.lat = self.lat
            venue.lon = self.lon
            venue.UpdateInDatabase()
        }
        
        
        
    }

    func DisplayUserInfo() {
        //Display whatever data is available
        if self.userType == "artist" {
            //Hide and unhide user type specific fields
            
            
            print("Displaying Artist info to view UserInfo")
            //It's an artist
            txtName.text = artist.name
            txtBio.text = artist.bio
            txtDOB.text = artist.dob
            txtGender.text = artist.gender
            txtGenre.text = artist.genre
            txtArtistType.text = artist.type
            
            if artist.photos.count > 0 {
                FIRStorage.storage().reference(forURL: artist.photos[0]).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                    let image = UIImage(data: data!)
                    self.imgProfPic.image = image
                })
            }
        }else{
            print("Displaying Venue info to view UserInfo")
            //Hide and unhide user specific views
            self.ArtistDetailView.isHidden = true
            self.VenueDetailView.isHidden = false
            
            txtName.text = venue.name
            txtBio.text = venue.bio
            txtCapacity.text = String(venue.capacity)
            txtAddress.text = venue.address
            
            if venue.photos.count > 0 {
                FIRStorage.storage().reference(forURL: venue.photos[0]).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                    let image = UIImage(data: data!)
                    self.imgProfPic.image = image
                })
            }
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.lat = locValue.latitude
        self.lon = locValue.longitude
        //print("Updated user location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            print("Requesting always location auth")
            manager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            print("Starting location updates")
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            print("Starting location updates")
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            print("Location restricted e.g. parental controls, nothing user can do")
            break
        case .denied:
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
        self.txtBio.layer.borderColor = UIColor.white.cgColor
        self.txtBio.layer.cornerRadius = 10.0
        //Make profile pic rounded
        self.imgProfPic.layer.borderWidth = 1
        self.imgProfPic.layer.masksToBounds = false
        self.imgProfPic.layer.borderColor = UIColor.white.cgColor
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.height/2
        self.imgProfPic.layer.cornerRadius = self.imgProfPic.frame.width/2
        self.imgProfPic.clipsToBounds = true
        
        //Hide / Unhide Artist and Venue detail views
        if self.userType == "artist" {
            self.ArtistDetailView.isHidden = false
            self.VenueDetailView.isHidden = true
            
        }else{
            self.ArtistDetailView.isHidden = true
            self.VenueDetailView.isHidden = false
        }
    }
    
       //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.

        view.endEditing(true)
        
        //Call to save all the data for the user
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func datePickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.long
        let strDate = dateFormatter.string(from: datePicker.date)
        self.txtDOB.text = strDate
    }

    @IBAction func txtDOBEditingDidEnd(_ sender: AnyObject) {
        self.Save()
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
