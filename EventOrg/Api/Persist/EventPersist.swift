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
    
    func doSave(){
        DispatchQueue.global(qos: .utility).async {
            do {
                let insert = EventTable.table.insert(EventTable.name <- self.name, EventTable.image <- self.image)
                let id = try self.dataBase.run(insert)
                self.id = id
                print("Event was successfully saved")
            } catch{
                print("Event saving failed: \(error)")
            }
            
            self.members.forEach({$0.save()})
            self.bills.forEach({$0.save()})
        }
    }
    
    // Удалить event
    func doDelete()
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
    func doUpdate()
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
