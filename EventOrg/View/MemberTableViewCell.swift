//
//  MemberTableViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 12/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    var delegate: MemberTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func enabledChanged(_ sender: UISwitch) {
        delegate?.updateMemberEnabled(sender: self)
    }
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var debt: UILabel!

    @IBOutlet weak var memberEnabled: UISwitch!
    
    func setName(_ name: String){
        memberName.text = name
    }
    
    func setEnabled(_ enabled: Bool){
        memberEnabled.isOn = enabled
    }
    
    func setDbt(_ val: Double){
        debt.text = String(format: POHelper.currencyFormat, val)
    }
}


protocol MemberTableViewCellDelegate: class {
    func updateMemberEnabled(sender: MemberTableViewCell)
}
