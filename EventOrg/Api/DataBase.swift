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
            
            if false {
                try db!.run(EventTable.table.drop(ifExists: true))
                try db!.run(MemberTable.table.drop(ifExists: true))
                try db!.run(BillTable.table.drop(ifExists: true))
                try db!.run(MemberInBillTable.table.drop(ifExists: true))
            }
            
            try db!.run(EventTable.table.create(ifNotExists: true) { table in
                table.column(EventTable.id, primaryKey: .autoincrement)
                table.column(EventTable.name)
                table.column(EventTable.image)
            })
            
            try db!.run(MemberTable.table.create(ifNotExists: true) { table in
                table.column(MemberTable.id, primaryKey: .autoincrement)
                table.column(MemberTable.name)
                table.column(MemberTable.event_id)
                table.foreignKey(MemberTable.event_id, references: EventTable.table, EventTable.id, delete: .cascade)
            })
            
            try db!.run(BillTable.table.create(ifNotExists: true) { table in
                table.column(BillTable.id, primaryKey: .autoincrement)
                table.column(BillTable.name)
                table.column(BillTable.cost)
                table.column(BillTable.event_id)
                table.foreignKey(BillTable.event_id, references: EventTable.table, EventTable.id, delete: .cascade)
            })
            
            try db!.run(MemberInBillTable.table.create(ifNotExists: true) { table in
                table.column(MemberInBillTable.id, primaryKey: .autoincrement)
                table.column(MemberInBillTable.debt)
                table.column(MemberInBillTable.manually)
                table.column(MemberInBillTable.event_id)
                table.column(MemberInBillTable.bill_id)
                table.column(MemberInBillTable.member_id)
                
                table.foreignKey(MemberInBillTable.event_id, references: EventTable.table, EventTable.id, delete: .cascade)
                table.foreignKey(MemberInBillTable.bill_id, references: BillTable.table, BillTable.id, delete: .cascade)
                table.foreignKey(MemberInBillTable.member_id, references: MemberTable.table, MemberTable.id, delete: .cascade)
            })
            
            print("Scheme created")
        } catch {
            print("Unable to create table")
        }
    }
    
    func getAllEvents(callback: (Event) -> Void) {
        var events = [Event]()
        
        var cnt = 0
        do {
            for row in try db!.prepare(EventTable.table) {
                let event = Event(
                    id: row[EventTable.id],
                    name: row[EventTable.name],
                    withPic: row.get(EventTable.image))
                events.append(event)
                cnt += 1
                callback(event)
            }
        } catch {
            print("Events loading failed")
        }
        print("Events loaded. Count \(cnt)")
        
        cnt = 0
        do {
            for row in try db!.prepare(MemberTable.table) {
                let event_id = row[MemberTable.event_id]
                guard let event = events.first(where: {$0.id == event_id}) else{
                    continue
                }
                
                let member = Member(id: row[MemberTable.id], row[MemberTable.name], owner: event)
                                
                event.add(member: member)
                cnt += 1
            }
        } catch {
            print("Members loading failed")
        }
        print("Members loaded. Count: \(cnt)")
        
        
        cnt = 0
        do {
            for row in try db!.prepare(BillTable.table) {
                let event_id = row[BillTable.event_id]
                guard let event = events.first(where: {$0.id == event_id}) else{
                    continue
                }
                
                let bill = Bill(id: row[BillTable.id], name: row[BillTable.name], cost: row[BillTable.cost], owner: event)
                
                event.add(bill: bill)
                cnt += 1
            }
        } catch {
            print("Bills loading failed: \(error.localizedDescription)")
        }
        print("Bills loaded. Count: \(cnt)")
        
        cnt = 0
        do {
            for row in try db!.prepare(MemberInBillTable.table) {
                let event_id = row[MemberInBillTable.event_id]
                guard let event = events.first(where: {$0.id == event_id}) else{
                    continue
                }
                
                let bill_id = row[MemberInBillTable.bill_id]
                guard let bill = event.bills.first(where: {$0.id == bill_id}) else{
                    continue
                }
                
                let member_id = row[MemberInBillTable.member_id]
                guard let member = event.members.first(where: {$0.id == member_id}) else{
                    continue
                }
                
                let memInBill = MemberInBill(id: row[MemberInBillTable.id], debt: row[MemberInBillTable.debt], manually: row[MemberInBillTable.manually], bill: bill, member: member)
                
                bill.membersInBills.append(memInBill)
                member.membersInBills.add(memInBill)
                
                cnt += 1
            }
        } catch {
            print("MemberInBills loading failed: \(error.localizedDescription)")
        }
        print("MemberInBills loaded. Count: \(cnt)")
        
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

extension Persist{
    func save(){
        DispatchQueue.global(qos: .utility).async {
            self.doSave()
        }
    }
    func update(){
        DispatchQueue.global(qos: .utility).async {
            self.doUpdate()
        }
    }
    func delete(){
//        DispatchQueue.global(qos: .utility).async {
            self.doDelete()
//        }
    }
}
