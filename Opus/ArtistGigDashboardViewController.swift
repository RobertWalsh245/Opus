//
//  ArtistGigDashboardViewController.swift
//  Opus
//
//  Created by Rob on 11/28/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class ArtistGigDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let GigCellReuseIdentifier = "gigcell"
    let OfferCellReuseIdentifier = "offercell"
    var artist = Artist()
    var TableRow = 0
    var DisplayType = "offers"
    
    @IBOutlet weak var lblOpenOffers: UILabel!
    @IBOutlet weak var GigTableView: UITableView!
    
    @IBOutlet weak var lblActiveGigs: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Get venue object from tabbar property
        
        
        GigTableView.delegate = self
        GigTableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.RefreshTable),
                       name: NSNotification.Name(rawValue: "OfferInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.RefreshTable),
                       name: NSNotification.Name(rawValue: "UserInit"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.RefreshTable),
                       name: NSNotification.Name(rawValue: "SetInit"),
                       object: nil)
        //artist.uid = Singleton.shared.UID
        
        if artist.uid.isEmpty {
            if let tbc = self.tabBarController as? UserTabbar {
                self.artist = tbc.artist
            }
        }
        
        if !artist.uid.isEmpty{
            artist.GetOffers()
        }
        
        
    }
    
    //TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.DisplayType == "gigs"{
            return artist._gigs.count
        }else{
            return artist._offers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.DisplayType == "gigs"{
            let cell:GigCell = self.GigTableView.dequeueReusableCell(withIdentifier: GigCellReuseIdentifier) as! GigCell
            
            cell.lblName.text = artist._gigs[indexPath.row].name
            cell.lblDate.text = artist._gigs[indexPath.row].date
            cell.lblTime.text = artist._gigs[indexPath.row].time
            
            let setCount = artist._gigs[indexPath.row]._sets.count
            if setCount == 1 {
                cell.lblSets.text = String(setCount) + " Set"
            }else if setCount > 1 {
                cell.lblSets.text = String(setCount) + " Sets"
            } else {
                cell.lblSets.text = "No Sets"
            }
            return cell

        } else {
            //Display offers
            let cell:OfferCell = self.GigTableView.dequeueReusableCell(withIdentifier: OfferCellReuseIdentifier) as! OfferCell
            
            let currOffer = artist._offers[indexPath.row]
            
            if Singleton.shared.UID == currOffer.creatorid {
                //the current user is the creator
                cell.lblFrom.text = "Offer From: You"
                cell.lblTo.text = "Offer To: " + currOffer._venue.name
            }else {
                //the current user is the recipient
                cell.lblFrom.text = "Offer From: " + currOffer._venue.name
                cell.lblTo.text = "Offer To: You"
            }
            
            cell.lblTime.text = currOffer._set.time
            cell.lblRate.text = currOffer._DisplayRate
            return cell
        }
        
    }
    
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     print("Prepare for segue called")
     if(segue.identifier == "GigDetail") {
     let GigDetailVC = (segue.destination as! GigDetailViewController)
     GigDetailVC.gig = venue._gigs[GigRow]
     
     
     print("Venue Info on GigDashboard Vc")
     print(venue.uid)
     print(venue.name)
     
     }
     } */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set selected row to be used by prepare for segue to pass the right offer
        
       let DestinationVC = self.storyboard!.instantiateViewController(withIdentifier: "OfferViewController") as! OfferViewController
        DestinationVC.offer = artist._offers[indexPath.row]
        DestinationVC.artist = artist
        DestinationVC.venue = artist._offers[indexPath.row]._venue
        DestinationVC.gig = artist._offers[indexPath.row]._gig
        self.navigationController?.pushViewController(DestinationVC, animated: true)
        navigationController?.isNavigationBarHidden = false
       
        
        
    }
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func GotOffer(_ notification: Notification) {
        //Catches notification from offer class
        if notification.userInfo!["success"] != nil  {
            
        }else{
            //Something went wrong
            print("Something went wrong retrieving the offer")
        }
    }
    
    func RefreshTable() {
        self.GigTableView.reloadData()
        self.lblOpenOffers.text = "Open Offers: " + String(artist._offers.count)
        
      //  lblGigs.text = String(venue._gigs.count) + " Active Gigs"
    }
    
    deinit {
        print("Deinit for ArtistGigDashboardVendor called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear called for ArtistGigDashboardVendor")
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
