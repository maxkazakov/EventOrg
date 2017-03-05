//
//  BillTableViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 19/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cost: UILabel!
    
}
