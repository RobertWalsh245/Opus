//
//  GigInfoViewController.swift
//  Opus
//
//  Created by Rob on 11/7/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class GigInfoViewController: UIViewController, UIPickerViewDelegate, UITextViewDelegate {
    
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
    
    var gig: Gig = Gig()
    
    let SetDurationPickerView = UIPickerView()
    var SetDurationRow = 0
    let GenrePickerView = UIPickerView()
    var GenreRow = 0
    let SetDurationTypes = ["10 Mins", "20 Mins" , "30 Mins", "45 Mins", "1 Hour", "1.5 Hour", "2 Hours or >"]
    let GenreTypes = ["Any", "Alternative",  "Classical", "Electronic", "Heavy Metal", "Hip Hop", "Rock"]
    
    weak var activeField: UITextField?
    weak var activeTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set default values
        txtSetDuration.text = "45 Mins"
        SetDurationRow = 3
        txtGenre.text = "Any"
        GenreRow = 0
        txtSetNumber.text = "1"
        txtTime.text = "8:00 PM"
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        txtDate.text = dateFormatter.string(from: currentDate)
        
        
        
        //Initialize picker views and link them to their textviews. Tag will tell the picker view methods below which data source to use. Tag on text box is used in textfield began editing to set initial value
        txtViewDescription.delegate = self
        
        SetDurationPickerView.delegate = self
        SetDurationPickerView.tag = 0
        txtSetDuration.inputView = SetDurationPickerView
        txtSetDuration.tag = 0
        
        
        GenrePickerView.delegate = self
        GenrePickerView.tag = 1
        txtGenre.inputView = GenrePickerView
        txtGenre.tag = 0
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Subscribe to observe the notification that that the user was Initialized
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.ValidAddressReceived(_:)),
                       name: NSNotification.Name(rawValue: "ValidAddress"),
                       object: nil)
    }


//Outlets
    @IBAction func btnSavePressed(_ sender: UIButton) {
        SetValues()
    }
    
    @IBOutlet var btnDiscardPressed: UIButton!
    
    @IBAction func btnSetPicturePressed(_ sender: UIButton) {
    }
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
        if !(txtSetNumber.text?.isEmpty)! {
            gig.sets = Int(txtSetNumber.text!)!
        }
        gig.date = txtDate.text!
        gig.time = txtTime.text!
        gig.setduration = txtSetDuration.text!
        
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
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return SetDurationTypes[row]
        }else if pickerView.tag == 1 {
            return GenreTypes[row]
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
        }
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
