//
//  Offer.swift
//  Opus
//
//  Created by Rob on 11/23/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation
import Firebase

class Offer {
    fileprivate var _StorageRef = FIRStorage.storage().reference(forURL: "gs://opus-f0c01.appspot.com")
    fileprivate var _OfferRef = FIRDatabase.database().reference().child("offers")
    fileprivate var _UserRef = FIRDatabase.database().reference().child("users")
    
    var oid: String = ""
    var sid: String = ""
    var creatorid: String = ""
    var recipientid: String = ""
    var vid: String = ""
    var aid: String = ""
    var cid: String = ""
    var gid: String = ""
    var rate: Double = 0.00
    var prevrate: Double = 0.00
    var accepted: Bool = false
    var creatortype: String = ""
    var creationdate: String = ""
    
    var _venue = Venue()
    var _artist = Artist()
    var _set = Set()
    var _gig = Gig()
    
    var _DisplayRate: String {
        get {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.currency
            // localize to your grouping and decimal separator
            currencyFormatter.locale = NSLocale.current
            let rateString = currencyFormatter.string(from: NSNumber(value: self.rate))
            return rateString!
        }
    }
    

    
    
    

    func RetrieveWithID (_ oid: String) {
        
        //Retrieve user from DB with given UID
        _OfferRef.child(oid).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("Retrieved the below user and attributes:")
            //print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
            
            self.oid = oid
            if let val = (snapshot.value as AnyObject).value(forKey: "sid"){
                self.sid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "creatorid"){
                self.creatorid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "recipientid"){
                self.recipientid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "cid"){
                self.cid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "rate"){
                self.rate = (val as! Double)}
            if let val = (snapshot.value as AnyObject).value(forKey: "accepted"){
                self.accepted = (val as! Bool)}
            if let val = (snapshot.value as AnyObject).value(forKey: "creatortype"){
                self.creatortype = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "creationdate"){
                self.creationdate = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "gid"){
                self.gid = (val as! String)}
            
            //Set the offers objects based on who created the offer
            if self.creatortype == "artist" {
                self._artist.RetrieveArtistForUser(self.creatorid)
                self._venue.RetrieveVenueForUser(self.recipientid)
            }else if self.creatortype == "venue"{
                self._artist.RetrieveArtistForUser(self.recipientid)
                self._venue.RetrieveVenueForUser(self.creatorid)
            }
            
            //Get the set
            self._set.RetrieveWithID(self.sid)
            
            //Get the Gig
            self._gig.RetrieveWithID(self.gid)
            
            
            //Post notification that the user was initalized from the database succesfully, include the user info success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "OfferInit"),
                    object: self,
                    userInfo: ["success": true])
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "OfferInit"),
                    object: nil,
                    userInfo: nil)
        }
        
    }
    
    
    func setValuesForKeysWithDictionary(dict: Dictionary<String, AnyObject>) {
        //Initializes the offer based on a passed in dictionary
        if let val = dict["sid"] {
            self.sid = val as! String}
        if let val = dict["creatorid"] {
            self.creatorid = val as! String}
        if let val = dict["recipientid"] {
            self.recipientid = val as! String}
        if let val = dict["cid"] {
            self.sid = val as! String}
        if let val = dict["rate"] {
            self.rate = val as! Double}
        if let val = dict["accepted"] {
            self.accepted = val as! Bool}
        if let val = dict["creatortype"] {
            self.creatortype = val as! String}
        if let val = dict["creationdate"] {
            self.creationdate = val as! String}
        if let val = dict["gid"] {
            self.gid = val as! String}
    }

    
  /*  func SetArtistVenueObjects() {
        //Sets the Artist and venue based on the creator type
        if !creatorid.isEmpty && !recipientid.isEmpty {
            if creatortype == "artist" {
                _artist.RetrieveArtistForUser(creatorid)
                _venue.RetrieveVenueForUser(recipientid)
            }else if creatortype == "venue" {
                _artist.RetrieveArtistForUser(recipientid)
                _venue.RetrieveVenueForUser(creatorid)
            }
        }
    }
    
    func SetSetObject() {
        if !sid.isEmpty {
            _set.RetrieveWithID(sid)
        }
        
        
    } */
    
    
  /*  func setValuesForKeysWithDictionary(dict: Dictionary<String, AnyObject>) {
        //Initializes the gig based on a passed in dictionary
        //print("Setting gig values from dictionary")
        if let val = dict["sid"] {
            self.sid = val as! String}
        if let val = dict["gid"] {
            self.gid = val as! String}
        if let val = dict["aid"] {
            self.aid = val as! String}
        if let val = dict["duration"]{
            self.duration = (val as! String)}
        if let val = dict["genre"]{
            self.genre = (val as! String)}
        if let val = dict["time"]{
            self.time = (val as! String)}
        if let val = dict["rate"]{
            self.rate = (val as! Double)}
    } */
    
    
    func CreateInDatabase(){
        //Generate a unique id for the gig and set it as the GID
        let NewOfferRef = _OfferRef.childByAutoId()
        self.oid = NewOfferRef.key
        
        //Check for values mandatory properties before continuing
        if(!self.sid.isEmpty && self.rate >= 0 && !self.creatorid.isEmpty && !self.recipientid.isEmpty  && !self.oid.isEmpty && !self.gid.isEmpty){
            
            let currentDateTime = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long
            dateFormatter.timeStyle = DateFormatter.Style.long
            let strDate = dateFormatter.string(from: currentDateTime)

            
            let OfferDict: [String: Any] =  [
                "sid": self.sid,
                "creatorid": self.creatorid,
                "recipientid": self.recipientid,
                "creatortype": self.creatortype,
                "rate": self.rate,
                "accepted": false,
                "creationdate": strDate,
                "gid": self.gid]
            //Set the Values in DB
            NewOfferRef.setValue(OfferDict)
            
            //Set the OID as apart of the creators offers
            var dict: [String: Any] = [self.oid: "creator"]
            self._UserRef.child(self.creatorid).child("offers").updateChildValues(dict)
            
            //set the OID as part of the recipients offers
            dict = [self.oid: "recipient"]
            self._UserRef.child(self.recipientid).child("offers").updateChildValues(dict)
            
            print("Added offer ", "\(oid)", " to database")
        }else{
            print("No name and/or OID. Offer not added to database")
        }
    }
    
    func UpdateInDatabase() {
        //Check for values mandatory properties before continuing
        if(!self.sid.isEmpty && self.rate >= 0 && !self.creatorid.isEmpty && !self.recipientid.isEmpty  && !self.oid.isEmpty){
            
            //Reference to the GID of this gig object
            let NewOfferRef = self._OfferRef.child(oid)
            //Place attributes in dict to be passed to Firebase
            let OfferDict = self.toDict()
            //Set the Values in DB
            NewOfferRef.updateChildValues(OfferDict)
            print("Updated details for Offer ", "\(oid)", " in database")
        }else{
            print("No oid / recipient/ creator, incorrect rate / time. Offer not updated in database")
        }
        
    }
    
    
  /*  func isComplete() -> String {
        var message = "Complete"
        //Check for values in mandatory properties before continuing
        
        if self.duration.isEmpty{
            message = "Please provide a duration for the set"
        }else if self.rate <= 0.0 {
            message = "Please provide a positive rate for the set"
        }else if self.time.isEmpty {
            message = "Please set a time for the set"
            // }else if(self.gid.isEmpty) {
            // message = "Something went wrong. Please try again"
        }
        return message
    } */
    
    func toDict() -> [String:AnyObject] {
        //Converts all properties to dictionary, excludes any with a leading "_" character
        //print("Converting to dict")
        var dict = [String:AnyObject]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            let firstChar = child.label![(child.label?.startIndex)!]
            if firstChar != "_"{
                if let key = child.label {
                    dict[key] = child.value as? AnyObject
                }
            }
        }
        //  print(dict)
        return dict
    }

    

}
