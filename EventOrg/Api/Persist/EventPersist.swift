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
            print("Event was successfully saved")
        } catch{
            print("Event saving failed: \(error)")
        }
        
        members.forEach({$0.save()})
        bills.forEach({$0.save()})
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
            print("Event was successfully deleted")
        } catch {
            print("Event deletion failed \(error)")
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
            let row = EventTable.table.filter(EventTable.id == id)
            let update = row.update([
                EventTable.name <- self.name,
                EventTable.image <- self.image,
                ])
            try dataBase.run(update)
            print("Event was successfully updated")
        } catch {
            print("Event updating failed: \(error)")
        }
        
    }
}
