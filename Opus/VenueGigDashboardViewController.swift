//
//  GigDashboardViewController.swift
//  Opus
//
//  Created by Rob on 11/12/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class VenueGigDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnNewGig: UIButton!
    @IBOutlet weak var lblGigs: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var GigTableView: UITableView!
    
    var Gigs: [Gig] = []
    var GigRow = 0
    var venue = Venue()
    
    var ViewOnly = true
    
    let cellReuseIdentifier = "gigcell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        GigTableView.delegate = self
        GigTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        //Get venue object from tabbar property
        if venue.uid.isEmpty {
            if let tbc = self.tabBarController as? UserTabbar {
                self.venue = tbc.venue
            }
        }
        
        
        //Check if the logged in user is the venue being diplayed
        let VID = FIRAuth.auth()?.currentUser?.uid
        print("Logged in user is " + VID!)
        print("Passed in vid  is " + venue.uid)
        if  VID == venue.uid {
            self.ViewOnly = false
        }else {
            self.ViewOnly = true
        }
        
        
        //print(venue._gigs.count)
        if venue._gigs.count == 0 {
            self.venue.GetGigsForVID(VID: venue.uid, WithPhoto: true)
        } else {
            DisplayGigs()
        }
        
        
        self.InitialSetup()
       // let VID = FIRAuth.auth()?.currentUser?.uid
      //  if  VID != nil {
       //     self.venue.GetGigsForVID(VID: VID!)
       // }
        
        //Catches notifcation from Vendor class that the gigs were retrieved
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.GotGigs),
                       name: NSNotification.Name(rawValue: "GotGigsForVenue"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.GotGigPhoto),
                       name: NSNotification.Name(rawValue: "GigPhotoRetrieved"),
                       object: nil)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnNewGigPressed(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
       // let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GigInfoViewController") as! GigInfoViewController
       // self.present(nextViewController, animated:true, completion:nil)
        
        //Navigation controller
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.tintColor = UIColor.white
        let controller = storyBoard.instantiateViewController(withIdentifier: "GigEditViewController") as! GigEditViewController
        
        controller.venue = venue
        self.navigationController!.pushViewController(controller, animated: true)
        
    }

    func InitialSetup() {
        lblName.text = "Venue: " + venue.name
        
        if ViewOnly {
            btnNewGig.isHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            btnNewGig.isHidden = false
            self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
//TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venue._gigs.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GigCell = self.GigTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! GigCell
        
        let currGig = venue._gigs[indexPath.row]
        
        cell.imgPhoto.layer.borderWidth = 1
        cell.imgPhoto.layer.masksToBounds = false
        cell.imgPhoto.layer.borderColor = UIColor.white.cgColor
        cell.imgPhoto.layer.cornerRadius = cell.imgPhoto.frame.height/2
        cell.imgPhoto.layer.cornerRadius = cell.imgPhoto.frame.width/2
        cell.imgPhoto.clipsToBounds = true
        cell.imgPhoto.contentMode = .scaleAspectFill

        
        cell.lblName.text = currGig.name
        cell.lblDate.text = currGig.date
        cell.lblTime.text = currGig.time
        
        //Display the gig photo if we have it, if we dont display the venue photo if it has one AND we don't have a gig photo that is being loaded
        if currGig._img != nil {
            cell.imgPhoto.image = currGig._img
        } else if venue._img != nil && currGig.photoURL.isEmpty {
            cell.imgPhoto.image = venue._img
        }
        
        let setCount = currGig._sets.count
        if setCount == 1 {
            cell.lblSets.text = String(setCount) + " Set"
        }else if setCount > 1 {
            cell.lblSets.text = String(setCount) + " Sets"
        } else {
            cell.lblSets.text = "No Sets"
        }
        
        
        //cell.myView.backgroundColor = self.colors[indexPath.row]
        //cell.myCellLabel.text = self.animals[indexPath.row]
        
        return cell
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
        //Set selected row to be used by prepare for segue to pass the right gig
        GigRow = indexPath.row
        
        //Segue to giginfo view and set the gig object
        //performSegue(withIdentifier: "GigDetail", sender: UIViewController.self)
        
        let DestinationVC = self.storyboard!.instantiateViewController(withIdentifier: "GigDetailViewContoller") as! GigDetailViewController
        DestinationVC.gig = venue._gigs[indexPath.row]
        DestinationVC.venue = venue
        //let navController = UINavigationController(rootViewController: self)
        
        //self.present(self.navigationController, animated:true, completion: nil)
        
        self.navigationController?.pushViewController(DestinationVC, animated: true)
        navigationController?.isNavigationBarHidden = false

        
        
    }
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func GotGigs(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("Retrieved Gigs for venue on Venue Gig Dashboard")
            DisplayGigs()
        }else{
            //Something went wrong
            print("Something went wrong retrieving the gigs for the venue")
        }
    }
    
    func GotGigPhoto(_ notification: Notification) {
        if notification.userInfo!["success"] != nil  {
            print("Retrieved Gig Photo for gig on Venue Gig Dashboard")
            GigTableView.reloadData()
        }else{
            //Something went wrong
            print("Something went wrong retrieving the gig photo")
        }

        
    }
    
    func DisplayGigs() {
        self.GigTableView.reloadData()
        
        
        lblGigs.text = String(venue._gigs.count) + " Active Gig(s)"
    }
    
    deinit {
        print("Deinit for GigDashboardVendor called")
        //Removes listener of Notifications when de init
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewWillDisappear called for GigDashboardVendor")
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
