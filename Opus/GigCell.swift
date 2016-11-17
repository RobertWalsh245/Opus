//
//  GigCell.swift
//  Opus
//
//  Created by Rob on 11/16/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit

class GigCell: UITableViewCell {
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myCellLabel: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
