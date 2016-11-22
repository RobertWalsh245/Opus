//
//  SetCell.swift
//  Opus
//
//  Created by Rob on 11/21/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit

class SetCell: UITableViewCell {

    @IBOutlet weak var lblSetNumber: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
