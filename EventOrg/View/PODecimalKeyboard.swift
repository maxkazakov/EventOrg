//
//  PODecimalKeyboard.swift
//  EventOrg
//
//  Created by Максим Казаков on 09/03/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class PODecimalKeyboardProvider: UIToolbar {
    
    weak var textField: UITextField!
    var doneBtn: UIBarButtonItem!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        barStyle       = UIBarStyle.default
        
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(doneBtn)
        
        self.items = items
        self.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doneButtonAction(){
        textField.resignFirstResponder()
    }
    
    func applyKeyboard(toTextField tf: UITextField) {
        tf.inputAccessoryView = self
        textField = tf
    }
}
