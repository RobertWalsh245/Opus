//
//  GigInfoViewController.swift
//  Opus
//
//  Created by Rob on 11/7/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase



class GigEditViewController: UIViewController, UIPickerViewDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var txtRate: UITextField!
    @IBOutlet var lblError: UILabel!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var Image: UIImageView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtDate: UITextField!
    @IBOutlet var txtTime: UITextField!
    @IBOutlet var txtGenre: UITextField!
    @IBOutlet var txtSetNumber: UITextField!
    @IBOutlet var txtSetDuration: UITextField!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var txtCity: UITextField!
    @IBOutlet var txtState: UITextField!
    @IBOutlet var txtZIP: UITextField!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var txtViewDescription: UITextView!
    
    @IBOutlet weak var SetTableView: UITableView!
    var gig: Gig = Gig()
    
    let picker = UIImagePickerController()
    
    var venue: Venue! = Venue()
    
    let cellReuseIdentifier = "setcell"
    
    let SetDurationPickerView = UIPickerView()
    var SetDurationRow = 0
    let GenrePickerView = UIPickerView()
    var GenreRow = 0
    let StatePickerView = UIPickerView()
    var StateRow = 0
    let SetDurationTypes = ["10 Mins", "20 Mins" , "30 Mins", "45 Mins", "1 Hour", "1.5 Hour", "2 Hours or >"]
    let GenreTypes = ["Any", "Alternative",  "Classical", "Electronic", "Heavy Metal", "Hip Hop", "Rock"]
    let States = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    weak var activeField: UITextField?
    weak var activeTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialSetup()
        
        picker.delegate = self
        
        self.ScrollView.delaysContentTouches = true
        self.ScrollView.canCancelContentTouches = false
        self.ScrollView.panGestureRecognizer.delaysTouchesBegan = true
        
        
        SetTableView.delegate = self
        SetTableView.dataSource = self
        
        let save = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SetValues))
        
        navigationItem.rightBarButtonItems = [save]
        
        
        
        self.tabBarController?.tabBar.isHidden = true
        
        InitPickerViews()
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.keyboardDidShow(notification:)),
                       name: NSNotification.Name.UIKeyboardDidShow,
                       object: nil)
        
        nc.addObserver(self,
                       selector: #selector(self.keyboardWillBeHidden(notification:)),
                       name: NSNotification.Name.UIKeyboardWillHide,
                       object: nil)
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func InitialSetup() {
        
        //Make profile pic rounded
        self.Image.layer.borderWidth = 1
        self.Image.layer.masksToBounds = false
        self.Image.layer.borderColor = UIColor.white.cgColor
        self.Image.layer.cornerRadius = self.Image.frame.height/2
        self.Image.layer.cornerRadius = self.Image.frame.width/2
        self.Image.clipsToBounds = true
        self.Image.contentMode = .scaleAspectFill
        
        //Check if we are editing an existing gig
        if gig.gid.isEmpty {
            //This is a new gig
            //Check if the venue has an address and populate
            if !venue.address.isEmpty { txtAddress.text = venue.address}
            if !venue.city.isEmpty { txtCity.text = venue.city}
            if !venue.state.isEmpty { txtState.text = venue.state}
            if !venue.zip.isEmpty { txtZIP.text = venue.zip}
            
            //Set gig pic to default venue pic if available and also store url to that pic with gig
           // if venue._img != nil {
           //     gig._img = venue._img
           //     self.Image.image = gig._img
             //   gig.photoURL = venue.photos[0]
           // }
            
            //Set default values
            txtSetDuration.text = "45 Mins"
            SetDurationRow = 3
            txtGenre.text = "Any"
            GenreRow = 0
            
        }else{
            //This is an existing gig
            txtName.text = gig.name
            txtViewDescription.text = gig.description
            txtAddress.text = gig.address
            txtCity.text = gig.city
            txtState.text = gig.state
            txtZIP.text = gig.zip
            txtPhone.text = gig.phone
            //gig.sets = Int(txtSetNumber.text!)!
            txtDate.text = gig.date
            txtTime.text = gig.time
            if gig._img != nil {
                self.Image.image = gig._img
            }
        }
        
        
        //Set default values
        txtSetDuration.text = "45 Mins"
        SetDurationRow = 3
        txtGenre.text = "Any"
        GenreRow = 0
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        txtDate.text = dateFormatter.string(from: currentDate)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Subscribe to observe the notification that that the user was Initialized
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.ValidAddressReceived(_:)),
                       name: NSNotification.Name(rawValue: "ValidAddress"),
                       object: nil)
        
        self.navigationController?.isNavigationBarHidden = false

    }


//Outlets
    @IBAction func btnSavePressed(_ sender: UIButton) {
        SetValues()
    }
    
    @IBAction func btnAddSetPressed(_ sender: UIButton) {
        let NewSet = Set()
        NewSet.time = txtTime.text!
        NewSet.duration = txtSetDuration.text!
        NewSet.genre = txtGenre.text!
        NewSet.gid = self.gig.gid
       
        if !(txtRate.text?.isEmpty)! {
            NewSet.rate = Double(txtRate.text!)!
        }
        let msg = NewSet.isComplete()
        
        if msg == "Complete" {
            gig._sets.append(NewSet)
            txtTime.text = ""
            txtRate.text = ""
            self.SetTableView.reloadData()
            dismissKeyboard()  
        }else{
            print(msg)
        }
        
    }
   
    @IBOutlet var btnDiscardPressed: UIButton!
    
    
//DatePickers
    @IBAction func txtDateDidBeginEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        //Set maximum date to be 1 year from today, minimum date is current date
        datePickerView.maximumDate = (Calendar.current as NSCalendar).date(byAdding: .year, value: +2, to: Date(), options: [])
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerChanged), for: UIControlEvents.valueChanged)
    }
    func datePickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let strDate = dateFormatter.string(from: datePicker.date)
        self.txtDate.text = strDate
    }
    
    @IBAction func txtTimeDidBeginEditing(_ sender: UITextField) {
        let timePickerView:UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = UIDatePickerMode.time
        sender.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(self.timePickerChanged), for: UIControlEvents.valueChanged)
    }
    func timePickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let strDate = dateFormatter.string(from: datePicker.date)
        self.txtTime.text = strDate
    }

//TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gig._sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SetCell = self.SetTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SetCell
        
        cell.lblGenre.text = gig._sets[indexPath.row].genre
        cell.lblTime.text = gig._sets[indexPath.row].time
        cell.lblDuration.text = gig._sets[indexPath.row].duration
        
        cell.lblRate.text = gig._sets[indexPath.row]._DisplayRate
        
        cell.lblSetNumber.text = "Set " + String(indexPath.row + 1)
        
        //Need to add artist name too
 
 
        //cell.myView.backgroundColor = self.colors[indexPath.row]
        //cell.myCellLabel.text = self.animals[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
       // if(segue.identifier == "GigDetail") {
         //   let GigDetailVC = (segue.destination as! GigDetailViewController)
           // GigDetailVC.gig = venue.gigs[GigRow]
       // }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set selected row to be used by prepare for segue to pass the right gig
        //GigRow = indexPath.row
        
        //Segue to giginfo view and set the gig object
        //performSegue(withIdentifier: "GigDetail", sender: UIViewController.self)
        
        
    }
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        
        //if otherGestureRecogizer.view = UITableView {
        //    return true
        //}


        return true
    }

//Functions
    
//Saving
    func SetValues() {
        gig.vid = (FIRAuth.auth()?.currentUser?.uid)!
        gig.name = txtName.text!
        gig.description = txtViewDescription.text
        gig.address = txtAddress.text!
        gig.city = txtCity.text!
        gig.state = txtState.text!
        gig.zip = txtZIP.text!
        gig.phone = txtPhone.text!
        //gig.sets = Int(txtSetNumber.text!)!
        
        gig.date = txtDate.text!
        gig.time = txtTime.text!
        
        //Calls an asynch conversion caught by a notifcation, if successful will call Save()
        gig.AddressToLatLon()
    }
    func ValidAddressReceived(_ notification: Notification) {
        //Catches notification from gig class
        self.Save()
    }
    func Save() {
        //Check if gig is complete
        let message = gig.isComplete()
        if message == "Complete" {
            //Save the gig to the database
            //Save gig to database
            print("Attempting to save Gig to database")
            //If the GID is empty that means this is a new gig so create it first
            if gig.gid.isEmpty {
                gig.CreateInDatabase()
            }
            gig.UpdateInDatabase()
            
            if gig._img != nil {
                //If the gig already had a unique photo, delete it and save the new one in its place
                if !gig.photoURL.isEmpty {
                    gig.DeletePhoto(gig.photoURL)
                }
                gig.SavePhoto(gig._img!)
            }
            
            DisplayError(message: "Gig saved succesfully!")
            navigationController?.popViewController(animated: true)
            
        }else {
            //Tell the user what is missing
            DisplayError(message: message)
            print(message)
        }
    }
    
//Picker Views
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return SetDurationTypes.count
        }else if pickerView.tag == 1 {
            return GenreTypes.count
        }else if pickerView.tag == 2 {
            return States.count
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return SetDurationTypes[row]
        }else if pickerView.tag == 1 {
            return GenreTypes[row]
        }else if pickerView.tag == 2 {
            return States[row]
        }
        
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            txtSetDuration.text = SetDurationTypes[row]
            SetDurationRow = row
        }else if pickerView.tag == 1 {
            txtGenre.text = GenreTypes[row]
            GenreRow = row
        }else if pickerView.tag == 2 {
            txtState.text = States[row]
            StateRow = row
        }
    }
    func donePicker (sender:UIBarButtonItem)
    {
        dismissKeyboard()
    }
    func InitPickerViews() {
        //Create tool bar for picker views
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        
        
        //Initialize picker views and link them to their textviews. Tag will tell the picker view methods below which data source to use. Tag on text box is used in textfield began editing to set initial value
        txtViewDescription.delegate = self
        
        SetDurationPickerView.delegate = self
        SetDurationPickerView.tag = 0
        SetDurationPickerView.showsSelectionIndicator = true
        txtSetDuration.inputView = SetDurationPickerView
        txtSetDuration.inputAccessoryView = toolBar
        txtSetDuration.tag = 0
        
        
        GenrePickerView.delegate = self
        GenrePickerView.tag = 1
        GenrePickerView.showsSelectionIndicator = true
        txtGenre.inputView = GenrePickerView
        txtGenre.inputAccessoryView = toolBar
        txtGenre.tag = 1
        
        StatePickerView.delegate = self
        StatePickerView.tag = 2
        StatePickerView.showsSelectionIndicator = true
        txtState.inputView = StatePickerView
        txtState.inputAccessoryView = toolBar
        txtState.tag = 1
        
        
        
    }
    func DisplayError(message: String) {
        
        self.lblError.text = message
        // Fade the label in and out
        let animationDuration = 0.5
        let delay = 1.5
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.lblError.alpha = 1
        }, completion: { (Bool) -> Void in
            // After the animation completes, fade out the view after a delay
            UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.lblError.alpha = 0
            },
                           completion: nil)
        })

    }
//Photo Picker
    
    @IBAction func btnSetPicturePressed(_ sender: UIButton) {
        print("Upload Gig photo pressed")
        
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
        
        self.Image.layer.cornerRadius = self.Image.frame.size.width / 2
        self.Image.contentMode = .scaleAspectFill
        gig._img = image
        self.Image.image = image
        
        //print("Saving photo")
        
        
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    
//Keyboard Management
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        self.activeField = nil
    }
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        self.activeField = sender
        if sender.tag == 0 {
            //It's the set duration textview set picker to inital value
            SetDurationPickerView.selectRow(SetDurationRow, inComponent: 0, animated: true)
        }else if sender.tag == 1 {
            //It's the Genre duration textfield set picker inital value
            SetDurationPickerView.selectRow(GenreRow, inComponent: 0, animated: true)
        }else if sender.tag == 2 {
            //It's the State duration textfield set picker inital value
            SetDurationPickerView.selectRow(StateRow, inComponent: 0, animated: true)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.activeTextView = textView
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeTextView = nil
    }
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.ScrollView.contentInset = contentInsets
            self.ScrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.ScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        //Same logic for textview
        if let activeField = self.activeTextView, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.ScrollView.contentInset = contentInsets
            self.ScrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.ScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.ScrollView.contentInset = contentInsets
        self.ScrollView.scrollIndicatorInsets = contentInsets
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        //print("ViewWillDisappear for ArtistDashboard called")
        NotificationCenter.default.removeObserver(self)
        print("Gigs venue has = " + String(venue._gigs.count))
        super.viewWillDisappear(animated)
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
