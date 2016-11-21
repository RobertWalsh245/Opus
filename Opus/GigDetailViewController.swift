//
//  GigDetailViewController.swift
//  Opus
//
//  Created by Rob on 11/16/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit

class GigDetailViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSets: UILabel!
    @IBOutlet weak var lblSetDuration: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgGigPhoto: UIImageView!
    
    var gig = Gig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GigDetail View loaded")
        
        
        
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
        lblGenre.text = gig.genre
        lblSets.text = String(gig.sets) + " set(s)"
        lblSetDuration.text = String(gig.setduration)
        lblTime.text = gig.time
    }
    
    
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        
        
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
