//
//  OfferCell.swift
//  Opus
//
//  Created by Rob on 11/30/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit

class OfferCell: UITableViewCell {

    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
