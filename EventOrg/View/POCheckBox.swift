//
//  POCheckBox.swift
//  EventOrg
//
//  Created by Максим Казаков on 22/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class POCheckBox: UIButton {

    // Images
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "unchecked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
    
    
}
