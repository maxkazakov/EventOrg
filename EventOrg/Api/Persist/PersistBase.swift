//
//  PersistBase.swift
//  EventOrg
//
//  Created by Максим Казаков on 03/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

protocol Persist {
    associatedtype ValueType = Self
    
    func save()
    func update()
    func delete()
}

extension Persist{
    var dataBase: Connection{
        return DataBase.instance.db!
    }
}
