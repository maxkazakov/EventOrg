//
//  MemberPersist.swift
//  EventOrg
//
//  Created by Максим Казаков on 26/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

struct MemberTable {
    static let table = Table("member")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let event_id = Expression<Int64>("event_id")
}

extension Member: Persist{
    
    func doSave() {
        // сохраняем только если владелец есть
        guard let owner = self.owner else {
            return
        }
        let owner_id = owner.id
        
        guard owner_id >= 0 else {
            return
        }        
        do {
            let insert = MemberTable.table.insert(MemberTable.name <- self.name,                                                MemberTable.event_id <- owner_id)
            let id = try dataBase.run(insert)
            self.id = id
            print("Member was successfully saved")
        } catch{
            print("Member saving failed: \(error)")
        }
    }
    
    func doDelete() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let event = MemberTable.table.filter(MemberTable.id == id)
            try dataBase.run(event.delete())
            print("Member was successfully deleted")
        } catch {
            print("Member deletion failed \(error)")
        }
    }
    
    func doUpdate() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let row = MemberTable.table.filter(MemberTable.id == id)            
            let update = row.update([
                MemberTable.name <- self.name
                ])
            try dataBase.run(update)
            print("Member was successfully updated")
        } catch {
            print("Member updating failed: \(error)")
        }
    }
}
