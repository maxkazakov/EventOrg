//
//  Event.swift
//  EventOrg
//
//  Created by Максим Казаков on 29/01/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

struct NotificationTypes{
    // изменился долг одго из участников чека
    static let memberEnabledChanged = Notification.Name(rawValue: "MemberInBillDebtChanged")
}

protocol Assignable{
    associatedtype T
    func assign(fromObj obj: T)
}

class Event {
    var name: String;
    var image: UIImage?
    
    var members = [Member]()
    var bills = [Bill]()
    
    init(_ name: String, withPic pic: UIImage? = nil){
        self.name = name
        self.image = pic
    }
    
    func remove(member: Member){
        guard let idx = members.index(of: member) else {
            fatalError("Event does not contain this member")
        }
        members.remove(at: idx)
    }
    
    func remove(memberAt: Int){
        guard memberAt < members.count else {
            fatalError("Event does not contain this member")
        }
        members.remove(at: memberAt)
    }
    
    func remove(bill: Bill){
        guard let idx = bills.index(of: bill) else {
            fatalError("Event does not contain this bill")
        }
        bills.remove(at: idx)
    }
    
    func add(member: Member){
        members.append(member)
    }
    
    func add(bill: Bill){
        bills.append(bill)
    }
    
    var sumCost: Double {
        get{
            var res = 0.0
            for bill in bills{
                res += bill.cost
            }
            return res
        }
    }
}

// человек в тусовке
class Member: Equatable {
    
    var membersInBills = NSHashTable<MemberInBill>(options: .weakMemory)
    
    var name: String = ""
    // TODO для исключения человека из тусовки без удаления из списка
    var enabled: Bool = true
    
    init(_ name: String){
        self.name = name
    }
    
    var debt: Double{
        get{
            var res = 0.0
            guard enabled else{
                return res
            }
            for memInBill in membersInBills.allObjects{
                res += memInBill.debt
            }
            return res
        }
    }
    
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs === rhs
    }
    
    deinit {
        membersInBills.allObjects.forEach({$0.detach()})
        print("deinit member")
    }
}

// мужик в чеке
class MemberInBill: Equatable{
    weak var bill: Bill!
    weak var member: Member!
    
    deinit {
        print("deinit memberinbill")
    }
    
    func detach(){
        bill.remove(memberInBill: self)
    }
    public private(set) var debt: Double = 0.0
    
    init(bill: Bill, member: Member) {
        self.bill = bill
        self.member = member
    }
    
    static func == (lhs: MemberInBill, rhs: MemberInBill) -> Bool {
        return lhs === rhs
    }
    
    // withNotifyOther - если true - пересчитываем долг у других мужиков в чеке
    // с true должно вызываться только из viewcontroller-a в момент когда юзер руками правит долг
    func setDebt(_ debt: Double, withNotifyOther: Bool = false){
        if debt > bill.cost{
            self.debt = bill.cost
        }
        else{
            self.debt = debt
        }
        
        if withNotifyOther{
            // высчитываем как распределить остаток
            var rest = bill.cost - self.debt
            if rest < 0 {
                rest = 0.0
            }
            let otherCount = bill.membersInBills.count - 1
            guard otherCount > 0 else{
                return
            }
            rest = rest / Double(otherCount)
            let userInfo = ["debt" : rest]
            //            NotificationCenter.default.post(name: NotificationTypes.memberEnabledChanged, object: self, userInfo: userInfo)
        }
    }
}


class Bill: Equatable, Assignable{
    typealias T = Bill
    
    func assign(fromObj obj: Bill) {
        membersInBills = obj.membersInBills
        for mem in membersInBills{
            mem.bill = self
        }
        name = obj.name
        images = obj.images
        _cost = obj.cost
    }
    
    // Если копия, то при ее удалении не детачим участников в чеке.
    // См. deinit
    var name: String = ""
    var images: [UIImage] = []
    var membersInBills: [MemberInBill] = []
    
    
    static func == (lhs: Bill, rhs: Bill) -> Bool {
        return lhs === rhs
    }
    
    // like member
    private var _cost: Double = 0.0
    // like prop
    var cost: Double {
        get{
            return _cost
        }
        set{
            _cost = newValue
            // обновляем долг каждого члена, приравниваем к средней задолженности
            guard membersInBills.count > 0 else {
                return
            }
            let avg = cost / Double(membersInBills.count)
            for memInBill in membersInBills{
                memInBill.setDebt(avg)
            }
        }
    }
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberInBillDebtChanged), name: NotificationTypes.memberEnabledChanged, object: nil)
    }
    
    @objc func onMemberInBillDebtChanged(_ notification: Notification){
        // сендер есть ?
        guard let sender = notification.object as? MemberInBill else{
            return
        }
        
        guard let userInfo = notification.userInfo,
            let debt = userInfo["debt"] as? Double else{
                return
        }
        // меняем долг у всех, кроме отправщика
        for mem in membersInBills{
            if sender != mem{
                mem.setDebt(debt)
            }
        }
    }
    
    // добавление нового участника в чек
    func append(member: Member){
        let memberInBill = MemberInBill(bill: self, member: member)
        membersInBills.append(memberInBill)
        member.membersInBills.add(memberInBill)
    }
    
    func remove(memberInBillAt idx: Int){
        guard idx < membersInBills.count else{
            fatalError()
        }
        membersInBills.remove(at: idx)
    }
    
    func remove(memberInBill: MemberInBill){
        if let idx = membersInBills.index(of: memberInBill){
            membersInBills.remove(at: idx)
        }
    }
    
    // Получить всех связанных членов
    func getMembers() -> [Member]{
        return membersInBills.map{ $0.member }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



