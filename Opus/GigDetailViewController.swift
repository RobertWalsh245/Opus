//
//  GigDetailViewController.swift
//  Opus
//
//  Created by Rob on 11/16/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit

class GigDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSets: UILabel!
    @IBOutlet weak var lblSetDuration: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgGigPhoto: UIImageView!
    
    @IBOutlet weak var SetTableView: UITableView!
    
    let cellReuseIdentifier = "setcell"
    
    var gig = Gig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GigDetail View loaded")
        
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
        lblName.text = gig.name
        lblDate.text = gig.date
        lblDescription.text = gig.description
        //lblSets.text = String(gig.sets) + " set(s)"
        lblTime.text = gig.time
    }
    
    
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.lblRate.text = "$" + String(gig._sets[indexPath.row].rate)
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
