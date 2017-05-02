//
//  MemberInBillPersist.swift
//  EventOrg
//
//  Created by Максим Казаков on 30/04/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import Foundation
import SQLite

struct MemberInBillTable {
    static let table = Table("memberInBill")
    static let id = Expression<Int64>("id")
    static let manually = Expression<Bool>("manually")
    static let debt = Expression<Double>("debt")
    static let event_id = Expression<Int64>("event_id")
    static let member_id = Expression<Int64>("member_id")
    static let bill_id = Expression<Int64>("bill_id")
}

extension MemberInBill: Persist{
    func doSave() {
        let bill_id = self.bill.id
        let member_id = self.member.id
        // сохраняем только если зависимости уже в бд
        guard bill_id >= 0, member_id >= 0 else {
            return
        }
        
        let event_id = self.bill.owner.id
        assert(event_id >= 0)
        do {
            let insert = MemberInBillTable.table.insert(MemberInBillTable.manually <- self.editedManually,
                                                MemberInBillTable.debt <- self.debt,
                                                MemberInBillTable.member_id <- member_id,
                                                MemberInBillTable.bill_id <- bill_id,
                                                MemberInBillTable.event_id <- event_id)
            let id = try dataBase.run(insert)
            self.id = id
            print("MemberInBill was successfully saved")
        } catch{
            print("MemberInBill saving failed: \(error)")
        }
    }
    
    func doDelete() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let event = MemberInBillTable.table.filter(MemberInBillTable.id == id)
            try dataBase.run(event.delete())
            print("MemberInBill was successfully deleted")
        } catch {
            print("MemberInBill was successfully deleted")
        }
    }
    
    func doUpdate() {
        let id = self.id
        guard id >= 0 else{
            return
        }
        do {
            let row = MemberInBillTable.table.filter(MemberInBillTable.id == id)
            let update = row.update([
                MemberInBillTable.manually <- self.editedManually,
                MemberInBillTable.debt <- self.debt,
                MemberInBillTable.bill_id <- self.bill.id,
                MemberInBillTable.member_id <- self.member.id,
                MemberInBillTable.event_id <- self.bill.owner.id
                ])
            try dataBase.run(update)
            print("MemberInBill was successfully updated")
        } catch {
            print("MemberInBill updating failed: \(error)")
        }
    }
}
