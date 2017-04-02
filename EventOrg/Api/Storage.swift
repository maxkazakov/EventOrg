//
//  LibraryAPI.swift
//  EventOrg
//
//  Created by Максим Казаков on 04/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class DataStorage: NSObject {
    static let instance = DataStorage();
    
    private let db: DataBase
    
    private var events: [Event]!
    
    override init(){
        db = DataBase()
    }
    
    func add(event: Event){
        let id = db.insertEvent(event)
        event.id = id
        events.append(event)
    }
    
    func delete(rowId: Int){
        let event = events.remove(at: rowId)
        db.deleteEvent(idx: event.id)
    }
    
    func getEvents() -> [Event]{
        if (events == nil){
            events = db.selectAllEvents()
        }
        return events
    }
}
