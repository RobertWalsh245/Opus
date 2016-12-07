//
//  OfferViewController.swift
//  Opus
//
//  Created by Rob on 11/23/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class OfferViewController: UIViewController {

    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblRecipientName: UILabel!
    @IBOutlet weak var lblGigName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSetRank: UILabel!
    @IBOutlet weak var lblSetTime: UILabel!
    @IBOutlet weak var lblSetDuration: UILabel!
    
    @IBOutlet weak var lblCreatorName: UILabel!
    @IBOutlet weak var lblPostedRate: UILabel!
    @IBOutlet weak var txtOfferRate: UITextField!
    
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnMakeOffer: UIButton!
    @IBOutlet weak var btnAcceptOffer: UIButton!
    
    var SetRank = 1
    
    var gig: Gig = Gig()
    var set = Set()
    var artist = Artist()
    var venue = Venue()
    var offer = Offer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialSetup()
        
        //Looks for single or multiple taps to dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
       /* if !self.offer.oid.isEmpty {
            //We were passed an offer, retrieve the artist, venue and set object
            if offer.creatortype == "artist" {
                //Only retrieve an artist/venue if we don't have the object already
                if venue.uid.isEmpty {
                    venue.RetrieveVenueForUser(offer.recipientid)
                }
                if artist.uid.isEmpty {
                   artist.RetrieveArtistForUser(offer.creatorid)
                }
            }else if offer.creatortype == "venue" {
                //Only retrieve an artist/venue if we don't have the object already
                if venue.uid.isEmpty {
                    venue.RetrieveVenueForUser(offer.creatorid)
                }
                if artist.uid.isEmpty {
                    artist.RetrieveArtistForUser(offer.recipientid)
                }
            }
            set.RetrieveWithID(offer.sid)
            
        }else {
            //We don't have an offer, we are creating a new one
            InitialSetup()
        } */
        
        
        InitialSetup()
        DisplayData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.DisplayData),
                       name: NSNotification.Name(rawValue: "OfferInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.DisplayData),
                       name: NSNotification.Name(rawValue: "UserInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.DisplayData),
                       name: NSNotification.Name(rawValue: "SetInit"),
                       object: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func DisplayData(){
        if gig._img != nil {
            self.image.image = gig._img
        }
        
        if offer.creatortype == "artist"{
            lblCreatorName.text = artist.name
            lblRecipientName.text = venue.name
        } else if offer.creatortype == "venue"{
            lblCreatorName.text = venue.name
            lblRecipientName.text = artist.name
        }
        
        lblRecipientName.text = venue.name
        lblGigName.text = gig.name
        lblDate.text = gig.date
        
        lblSetRank.text = "Set " + String(SetRank) + " out of " + String(gig._sets.count)
        
        lblSetTime.text = set.time
        lblSetDuration.text = set.duration
        
        lblPostedRate.text = "Posted Rate: " + set._DisplayRate
        txtOfferRate.text = offer._DisplayRate
    }
    func InitialSetup() {
        self.image.layer.cornerRadius = self.image.frame.size.width / 2
        self.image.contentMode = .scaleAspectFill
        
        if Singleton.shared.UID == offer.creatorid {
            btnMakeOffer.isHidden = false
            btnAcceptOffer.isHidden = true
        }else if Singleton.shared.UID == offer.recipientid {
            btnMakeOffer.isHidden = true
            btnAcceptOffer.isHidden = false
        }
        
        
    }
    
    @IBAction func txtOfferRateDidEndEditing(_ sender: UITextField) {
       //Bombs out if number already formatted as currency
        if !(txtOfferRate.text?.isEmpty)! {
           offer.rate = Double(txtOfferRate.text!)!
            txtOfferRate.text = offer._DisplayRate
        }
        
        
        /* let strRate = txtOfferRate.text
        print("Strrate = " + strRate!)
        if !(strRate?.isEmpty)! {
           let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.currency
            // localize to your grouping and decimal separator
            currencyFormatter.locale = NSLocale.current
            let rate = Double(strRate!)
            let rateString = currencyFormatter.string(from: NSNumber(value: rate!))
            self.txtOfferRate.text = rateString
        } */
    
    }
    
 @IBAction func btnMakeOfferPressed(_ sender: UIButton) {
    if (txtOfferRate.text?.isEmpty)! {
        //There is no offer rate
        print("There is no offer rate")
    }
        //Set values
        SetValues()
        //Create Offer
        offer.CreateInDatabase()
    
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAcceptOfferPressed(_ sender: UIButton) {
        
        
    }
    @IBAction func btnChatPressed(_ sender: UIButton) {
        
    }
    func SetValues() {
        
        offer.creatorid = Singleton.shared.UID
        
        //Recipient should be the opposite user type from the user creating the offer
        if Singleton.shared.type == "artist" {
            offer.recipientid = venue.uid
        } else if Singleton.shared.type == "venue" {
            offer.recipientid = artist.uid
        }
        print("Offer rate pre format = " + String(offer.rate))
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let number = formatter.number(from: txtOfferRate.text!) {
            print("Rate post Numformatter = " + String(describing: number))
            offer.rate = Double(number)
            print("Offer after Double = " + String(offer.rate))
        }
        offer.sid = set.sid
        offer.creatortype = Singleton.shared.type
        offer.gid = gig.gid
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
