//
//  BillMemberViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 23/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

protocol BillMemberViewCellDelegate: class{
    func onDebtChanged(_ cell: BillMemberViewCell, debt value: Double)
}

class BillMemberViewCell: UITableViewCell, UITextFieldDelegate, BillMemberViewCellDelegate {
    
    weak var delegate: BillMemberViewCellDelegate?
    
    internal func onDebtChanged(_ cell: BillMemberViewCell, debt value: Double) {
        delegate?.onDebtChanged(cell, debt: value)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        debt.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.setDecimalKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = Double(debt.text!) ?? 0.0
        onDebtChanged(self, debt: value)
    }

    func setManuallyImageHidden(_ value: Bool){
        manually.isHidden = value
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var debt: UITextField!
    @IBOutlet weak var manually: UIImageView!

}
