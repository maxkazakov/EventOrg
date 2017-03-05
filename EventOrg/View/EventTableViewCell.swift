//
//  EventTableViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 01/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var eventPic: UIImageView!

    @IBOutlet weak var eventName: UILabel!

    @IBOutlet weak var eventPrice: UILabel!
    
    func setEvent(_ event: Event){
        eventName.text = event.name
        eventPic.image = event.image
        eventPrice.text = String(format: "Price: %d$", event.sumCost)
    }
}
