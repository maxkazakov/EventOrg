//
//  BillMemberViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 23/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class BillMemberViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var debt: UITextField!

}
