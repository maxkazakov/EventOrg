//
//  BillPersist.swift
//  EventOrg
//
//  Created by Максим Казаков on 29/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

struct BillTable {
    static let table = Table("bill")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let cost = Expression<Double>("cost")
    static let event_id = Expression<Int64>("event_id")
}

extension Bill: Persist{
    func doSave() {
        let owner_id = self.owner.id
        // сохраняем только если владелец есть в бд
        guard owner_id >= 0 else {
            return
        }
        do {
            let insert = BillTable.table.insert(BillTable.name <- self.name,
                                                  BillTable.event_id <- owner_id,
                                                  BillTable.cost <- self.cost)
            let id = try dataBase.run(insert)
            self.id = id
            print("Bill was successfully saved")
        } catch{
            print("Bill saving failed: \(error)")
        }
        
        membersInBills.forEach({$0.save()})
    }
    
    func doDelete() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let event = BillTable.table.filter(BillTable.id == id)
            try dataBase.run(event.delete())
            print("Bill was successfully deleted")
        } catch {
            print("Bill deletion failed \(error)")
        }
    }
    
    func doUpdate() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let row = BillTable.table.filter(BillTable.id == id)
            let update = row.update([
                BillTable.name <- self.name,
                BillTable.cost <- self.cost
                ])
            try dataBase.run(update)
            print("Bill was successfully updated")
        } catch {
            print("Bill updating failed: \(error)")
        }
    }
}
