//
//  CheckMemberTableViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 22/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

protocol MemberToggleSelectDelegate: class {
    func toggleSelect(_ sender: UITableViewCell)
}

class CheckMemberTableViewCell: UITableViewCell, MemberToggleSelectDelegate {
    internal func toggleSelect(_ sender: UITableViewCell) {
        delegate?.toggleSelect(sender)
    }

    @IBOutlet weak var checkBtn: POCheckBox!
    @IBOutlet weak var nameTf: UILabel!
    weak var delegate: MemberToggleSelectDelegate?
    
    @IBAction func checkClick(_ sender: Any) {
        toggleSelect(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
