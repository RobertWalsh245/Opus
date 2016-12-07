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

class UserInfoViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtBio: UITextView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var imgProfPic: UIImageView!
 
//Artist Outlets
    @IBOutlet var ArtistDetailView: UIView!
    @IBOutlet var txtDOB: UITextField!
    @IBOutlet var txtGender: UITextField!
    @IBOutlet var txtGenre: UITextField!
    @IBOutlet var txtArtistType: UITextField!
    
    let ArtistTypes = ["Band", "Duet", "Solo Act"]
    let GenreTypes = ["Alternative",  "Classical", "Electronic", "Heavy Metal", "Hip Hop", "Rock"]
    let GenderTypes = ["Male", "Female"]
    
//Venue Outlets
    @IBOutlet var VenueDetailView: UIView!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var txtCapacity: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var AddressView: UIView!
    
    let StatePickerView = UIPickerView()
    var StateRow = 0
    let States = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

    
    var _Ref = FIRDatabase.database().reference()
    
    
    let picker = UIImagePickerController()
    var lat: Double! = 0.0
    var lon: Double! = 0.0
    
    var artist: Artist! = Artist()
    var venue: Venue! = Venue()
    var userType: String = ""
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Loaded UserInfoViewController")
        
        //Initialize picker views and link them to their textviews. Tag will tell the picker view methods below which data source to use
        let TypePickerView = UIPickerView()
        TypePickerView.delegate = self
        TypePickerView.tag = 0
        txtArtistType.inputView = TypePickerView
        
        let GenrePickerView = UIPickerView()
        GenrePickerView.delegate = self
        GenrePickerView.tag = 1
        txtGenre.inputView = GenrePickerView
        
        let GenderPickerView = UIPickerView()
        GenderPickerView.delegate = self
        GenderPickerView.tag = 2
        txtGender.inputView = GenderPickerView
        
        let StatePickerView = UIPickerView()
        StatePickerView.delegate = self
        StatePickerView.tag = 3
        txtState.inputView = StatePickerView
        
        picker.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        txtBio.delegate = self
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Subscribe to observe the notification that that the user was Initialized
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.PhotoRetrieved),
                       name: NSNotification.Name(rawValue: "PhotoRetrieved"),
                       object: nil)
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
        
        
        if !artist.uid.isEmpty {
            //We have an artist object
            userType = "artist"
            print("Passed an artist object displaying to view")
            self.InitialFormatting()
            self.DisplayUserInfo()
            self.DisplayPhoto()
        } else if !venue.uid.isEmpty {
            //We have a venue
            print("Passed a venue object, displaying to view")
            userType = "venue"
            self.InitialFormatting()
            self.DisplayUserInfo()
            self.DisplayPhoto()
        } else {
            //We don't have either, retrieve one
            print("No existing user object detected, retrieving from database")
            if Singleton.shared.type == "artist" {
                self.artist.RetrieveArtistForUser(Singleton.shared.UID)
            }else if Singleton.shared.type == "venue" {
                self.venue.RetrieveVenueForUser(Singleton.shared.UID)
            }
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
        if Singleton.shared.type == "artist" {
           performSegue(withIdentifier: "ArtistDashboard", sender: UIViewController.self)
        }else if Singleton.shared.type == "venue" {
            performSegue(withIdentifier: "VenueDashboard", sender: UIViewController.self)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
        if(segue.identifier == "VenueDashboard") {
            //let VenueDashboardVC = (segue.destination as! VenueDashboardViewController)
            //VenueDashboardVC.venue = venue
            
            let tabCtrl = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! VenueDashboardViewController
            destinationVC.venue = venue
            
        } else if (segue.identifier == "ArtistDashboard") {
            //let ArtistDashboardVC = (segue.destination as! ArtistDashboardViewController)
            //ArtistDashboardVC.artist = artist
            
            let tabCtrl = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! ArtistDashboardViewController
            destinationVC.artist = artist
            
        }
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
    func datePickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.long
        let strDate = dateFormatter.string(from: datePicker.date)
        self.txtDOB.text = strDate
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
        if (Singleton.shared.type == "artist"){
            artist.SavePhoto(image)
            artist._img = image
        }else{
            venue.SavePhoto(image)
            venue._img = image
        }

        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//
//Functions
//
    
//Initalization
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
            //Check if the returned user has a photo, if so retrieve the first of their photos
            if userType == "venue" {
                if venue.photos.count > 0 {
                    self.ActivityIndicator.startAnimating()
                    venue.RetrievePhoto(venue.photos[0])
                }
            } else if userType == "artist" {
                if artist.photos.count > 0 {
                    self.ActivityIndicator.startAnimating()
                    artist.RetrievePhoto(artist.photos[0])
                }
            }
            
            
            
            self.DisplayUserInfo()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }

    

    func Save() {
        //Called whenever editing on text box ends
        if (Singleton.shared.type == "artist"){
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
            //Need to check if valid number entered
            if Int(txtCapacity.text!) != nil
            {
                venue.capacity = Int(txtCapacity.text!)!
            }
            venue.lat = self.lat
            venue.lon = self.lon
            venue.address = txtAddress.text!
            venue.city = txtCity.text!
            venue.state = txtState.text!
            venue.zip = txtZip.text!
            venue.phone = txtPhone.text!
            
            venue.UpdateInDatabase()
        }
        
        
        
    }

    func DisplayUserInfo() {
        //Display whatever data is available
        if Singleton.shared.type == "artist" {
            //Hide and unhide user type specific fields
            print("Displaying Artist info to view UserInfo")
            //It's an artist
            txtName.text = artist.name
            txtBio.text = artist.bio
            txtDOB.text = artist.dob
            txtGender.text = artist.gender
            txtGenre.text = artist.genre
            txtArtistType.text = artist.type
            
        }else{
            print("Displaying Venue info to view UserInfo")
            //Hide and unhide user specific views
            self.ArtistDetailView.isHidden = true
            self.VenueDetailView.isHidden = false
            
            txtName.text = venue.name
            txtBio.text = venue.bio
            if venue.capacity > 0 {
                txtCapacity.text = String(venue.capacity)
            }
            txtAddress.text = venue.address
           
            txtCity.text = venue.city
            txtState.text = venue.state
            txtZip.text = venue.zip
            txtPhone.text = venue.phone

        }
        
    }
    
    func PhotoRetrieved(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("Photo retrieved successfully on UserInfoViewController")
            ActivityIndicator.stopAnimating()
            self.DisplayPhoto()
        }else{
            //Something went wrong
            // print("Something went wrong with initializing the user")
        }
    }
    
    func DisplayPhoto(){
        //print("Photo retrieved notified")
        if venue._img != nil {
            imgProfPic.image = venue._img
        }else if artist._img != nil {
            imgProfPic.image = artist._img
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
//Picker Views
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return ArtistTypes.count
        }else if pickerView.tag == 1 {
            return GenreTypes.count
        }else if pickerView.tag == 2 {
            return GenderTypes.count
        }else if pickerView.tag == 3 {
            return States.count
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return ArtistTypes[row]
        }else if pickerView.tag == 1 {
            return GenreTypes[row]
        }else if pickerView.tag == 2 {
            return GenderTypes[row]
        }else if pickerView.tag == 3 {
            return States[row]
        }
        
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            txtArtistType.text = ArtistTypes[row]
        }else if pickerView.tag == 1 {
            txtGenre.text = GenreTypes[row]
        }else if pickerView.tag == 2 {
            txtGender.text = GenderTypes[row]
        }else if pickerView.tag == 3 {
            txtState.text = States[row]
        }
    }
    
    @IBAction func txtArtistTypeEditingDidBegin(_ sender: UITextField) {
        //view.endEditing(true)
        
        
    }
    
    
    
    @IBAction func txtDOBEditingDidEnd(_ sender: UITextView) {
        self.Save()
    }
    
    func InitialFormatting() {
        //Called at view load
        
        //txtBio rounded corners
        //txtBio.layer.cornerRadius = 5
        
        
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
        self.imgProfPic.contentMode = .scaleAspectFill
        
        //Hide / Unhide Artist and Venue detail views
        if Singleton.shared.type == "artist" {
            self.ArtistDetailView.isHidden = false
            self.VenueDetailView.isHidden = true
            self.AddressView.isHidden = true
        }else{
            self.ArtistDetailView.isHidden = true
            self.VenueDetailView.isHidden = false
            self.AddressView.isHidden = false
        }
    }
       
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtBio.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        print(numberOfChars)
        return numberOfChars < 150
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
        print("Deinit for UserInfo called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear called for UserInfo")
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
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
