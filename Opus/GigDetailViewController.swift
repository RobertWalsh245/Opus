//
//  GigDetailViewController.swift
//  Opus
//
//  Created by Rob on 11/16/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

class GigDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnOfferToPlay: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSets: UILabel!
    @IBOutlet weak var lblSetDuration: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgGigPhoto: UIImageView!
    
    @IBOutlet weak var SetTableView: UITableView!

    var ViewOnly = true
    
    let cellReuseIdentifier = "setcell"
    
    var gig = Gig()
    var venue = Venue()
    
    var SelectedSetRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GigDetail View loaded")
        
        //Check if the logged in user is the creator of the gig
        let VID = FIRAuth.auth()?.currentUser?.uid
        //print("Logged in user is " + VID!)
        //print("Passed in gigs, vid  is " + gig.vid)
        if  VID == gig.vid {
            self.ViewOnly = false
        }else {
            self.ViewOnly = true
        }
        
        btnOfferToPlay.isEnabled = false
        
        InitialSetup()
        
        edgesForExtendedLayout = []
        
        SetTableView.delegate = self
        SetTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !self.gig.name.isEmpty {
        //The gig varible has been set, diaplay the info
        DisplayInfo()
        } else {
            //Display message saying something went wrong
        }
    }
    
    func DisplayInfo() {
        print("Displaying gig info")
        
        SetTableView.reloadData()
        lblName.text = gig.name
        lblDate.text = gig.date
        lblDescription.text = gig.description
        //lblSets.text = String(gig.sets) + " set(s)"
        lblTime.text = gig.time
        
        if gig._img != nil {
            self.imgGigPhoto.image = gig._img
        } else if venue._img != nil {
            self.imgGigPhoto.image = venue._img
        }
        
    }
    
    @IBAction func btnOfferToPlayPressed(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "OfferViewController") as! OfferViewController
        
        controller.venue = venue
        controller.gig = gig
        controller.set = gig._sets[SelectedSetRow]
        controller.SetRank = SelectedSetRow + 1
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "GigEditViewController") as! GigEditViewController
        
        controller.venue = venue
        controller.gig = gig
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func InitialSetup() {
        
        self.imgGigPhoto.layer.cornerRadius = self.imgGigPhoto.frame.size.width / 2
        self.imgGigPhoto.contentMode = .scaleAspectFill
        
        if ViewOnly {
            btnOfferToPlay.isHidden = false
            btnEdit.isHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            btnOfferToPlay.isHidden = true
            btnEdit.isHidden = false
            self.navigationController?.isNavigationBarHidden = false
        }
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
        
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            SelectedSetRow = indexPath.row
            btnOfferToPlay.isEnabled = true
        }
        
        //Segue to giginfo view and set the gig object
        //performSegue(withIdentifier: "GigDetail", sender: UIViewController.self)
        
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
            btnOfferToPlay.isEnabled = false
        }
    }
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
