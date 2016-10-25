//
//  Artist.swift
//  Opus
//
//  Created by Rob on 10/24/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation

import CoreLocation
import UIKit
import Firebase

class Artist : User {
    
    var AID: String = ""
    var gender: String = ""
    var genre: String = ""
    var type: String = ""
    
    
    //A reference to the users node in the database
    private var _ArtistRef = FIRDatabase.database().reference().child("artists")
    //A reference to the storage buckets within firebase
    private var _StorageRef = FIRStorage.storage().referenceForURL("gs://opus-f0c01.appspot.com")
    
    
    func RetrieveArtistsForUser(UID: String){
        print("Retrieving artists for user ", "\(UID)")
        let ref = self._ArtistRef
        ref.queryOrderedByChild("UID")
        //ref.query
    }
    
    override func CreateInDatabase(){
        
        //Check for values in mandatory properties before continuing
        if(!uid.isEmpty ){
            //Creates a randomly generated unique identifer for the Artist
            self.AID = self._ArtistRef.childByAutoId().key
            //Set path to create new node using generated AID
            let NewArtistRef = self._ArtistRef.child(self.AID)
            //Place attributes in dict to be passed to Firebase
            //let UserDict: AnyObject = ["email": email,
                                       //"accountcomplete": accountcomplete]
            let ArtistDict = self.toDict()
            //Set the Values in DB
            NewArtistRef.setValue(ArtistDict)
            print("Added Artist ", "\(uid)", " to database")
            
            //Add AID to Users data
            self.AddArtistToUser()
        }else{
            print("No UID. Artist not added to database")
        }
    }
    
    func AddArtistToUser() {
        print("Adding Artist to user data")
        super.
        
    }
    
    
    override func toDict() -> [String:AnyObject] {
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
        //Add properties of User superclass
        let SuperSelf = otherSelf.superclassMirror()
        for child in SuperSelf!.children {
            let firstChar = child.label![(child.label?.startIndex)!]
            if firstChar != "_"{
                if let key = child.label {
                    dict[key] = child.value as? AnyObject
                }
            }
        }
   
        print(dict)
        return dict
    }

}
