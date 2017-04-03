//
//  Helper.swift
//  EventOrg
//
//  Created by Максим Казаков on 26/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

// MARK : Helper static class
class POHelper{
    static var currencyFormat = "%.0f"
    static let decimalKeyboard = PODecimalKeyboardProvider()
}


extension UITextField {
    func setDecimalKeyboard() {
        POHelper.decimalKeyboard.applyKeyboard(toTextField: self)
    }
}


