//
//  GigDashboardViewController.swift
//  Opus
//
//  Created by Rob on 11/12/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class GigDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var GigTableView: UITableView!
    
    var Gigs: [Gig] = []
    var GigRow = 0
    var venue = Venue()
    
    let cellReuseIdentifier = "gigcell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GigTableView.delegate = self
        GigTableView.dataSource = self
        
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = "Discard"
        backItem.tintColor = UIColor.red
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.navigationBar.tintColor = UIColor.red
        
        let VID = FIRAuth.auth()?.currentUser?.uid
        if  VID != nil {
            self.venue.GetGigsForVID(VID: VID!)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        let VID = FIRAuth.auth()?.currentUser?.uid
        if  VID != nil {
            self.venue.GetGigsForVID(VID: VID!)
        }
        
        //Catches notifcation from Vendor class that the gigs were retrieved
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.GotGigs),
                       name: NSNotification.Name(rawValue: "GotGigsForVenue"),
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
        let controller = storyBoard.instantiateViewController(withIdentifier: "GigInfoViewController")
        self.navigationController!.pushViewController(controller, animated: true)
        
    }

//TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venue.gigs.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GigCell = self.GigTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! GigCell
        
        cell.lblName.text = venue.gigs[indexPath.row].name
        cell.lblDate.text = venue.gigs[indexPath.row].date
        cell.lblTime.text = venue.gigs[indexPath.row].time
        
        
        //cell.myView.backgroundColor = self.colors[indexPath.row]
        //cell.myCellLabel.text = self.animals[indexPath.row]
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
        if(segue.identifier == "GigDetail") {
            let GigDetailVC = (segue.destination as! GigDetailViewController)
            GigDetailVC.gig = venue.gigs[GigRow]
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set selected row to be used by prepare for segue to pass the right gig
        GigRow = indexPath.row
        
        //Segue to giginfo view and set the gig object
        performSegue(withIdentifier: "GigDetail", sender: UIViewController.self)
        
        
    }
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func GotGigs(_ notification: Notification) {
        //Catches notification from user class
        if notification.userInfo!["success"] != nil  {
            print("Retrieved " + String(self.venue.gigs.count) + " gig(s) for the venue")
            self.GigTableView.reloadData()
        }else{
            //Something went wrong
            print("Something went wrong retrieving the gigs for the venue")
        }
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
