//
//  DataBase.swift
//  EventOrg
//
//  Created by Максим Казаков on 01/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

class DataBase{
    
    struct EventTable {
        static let table = Table("event")
        static let id = Expression<Int64>("id")
        static let name = Expression<String>("name")
        static let image = Expression<UIImage?>("image")
    }
    
    let dbname = "userdata.db"
    private var db: Connection? = nil
    
    init() {
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentDirectory: URL = urls.first else {
            fatalError()
        }
        
        guard let _ = try? documentDirectory.checkResourceIsReachable() else{
            print("Document path is not reachable")
            return
        }
        
        // connect to db
        let dbpath = "\(documentDirectory.absoluteString)/\(dbname)"
        do{
            db = try Connection(dbpath)
        }
        catch{
            fatalError()
        }
        
        createScheme()
    }
    
    func createScheme() {
        do {
//            try db!.run(EventTable.table.drop())
            try db!.run(EventTable.table.create(ifNotExists: true) { table in
                table.column(EventTable.id, primaryKey: .autoincrement)
                table.column(EventTable.name)
                table.column(EventTable.image)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func selectAllEvents() -> [Event]{
        var events = [Event]()
        
        do {
            for event in try db!.prepare(EventTable.table) {
                events.append(Event(
                    id: Int(event[EventTable.id]),
                    name: event[EventTable.name],
                    withPic: event.get(EventTable.image)))
            }
        } catch {
            print("Select failed")
        }
        
        return events
    }
    
    func insertEvent(_ event: Event) -> Int{
        do {
            let insert = EventTable.table.insert(EventTable.name <- event.name, EventTable.image <- event.image)
            let id = try db!.run(insert)
            
            return Int(id)
        } catch{
            print(error)
            return -1
        }
    }
    
    func deleteEvent(idx: Int){
        do {
            let event = EventTable.table.filter(EventTable.id == Int64(idx))
            try db!.run(event.delete())
        } catch {
            print("Delete failed")
        }
    }

}

extension UIImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ datatypeValue: Blob) -> UIImage {
        return UIImage(data: Data.fromDatatypeValue(datatypeValue))!
    }
    public var datatypeValue: Blob {
        return UIImagePNGRepresentation(self)!.datatypeValue
    }
    
}
