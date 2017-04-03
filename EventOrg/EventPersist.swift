//
//  EventPersist.swift
//  EventOrg
//
//  Created by Максим Казаков on 03/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

struct EventTable {
    static let table = Table("event")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let image = Expression<UIImage?>("image")
}

extension Event: Persist{        
    
    func save(){
        do {
            let insert = EventTable.table.insert(EventTable.name <- self.name, EventTable.image <- self.image)
            let id = try dataBase.run(insert)
            self.id = id            
        } catch{
            print(error)
        }
    }
    
    // Удалить event
    func delete()
    {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let event = EventTable.table.filter(EventTable.id == id)
            try dataBase.run(event.delete())
        } catch {
            print("Delete failed \(error)")
        }
    }
    
    // Обновить event
    func update()
    {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let update = EventTable.table.update([
                EventTable.name <- self.name,
                EventTable.image <- self.image,
                ])
            try dataBase.run(update)
        } catch {
            print("Update failed: \(error)")
        }
        
    }
}
