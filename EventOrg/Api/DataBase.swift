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
    static let instance = DataBase()
    
    let dbname = "userdata.db"
    var db: Connection? = nil
    
    func run(){
        
    }
    
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
            // try db!.run(EventTable.table.drop())
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
                    id: event[EventTable.id],
                    name: event[EventTable.name],
                    withPic: event.get(EventTable.image)))
            }
        } catch {
            print("Select failed")
        }        
        return events
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
