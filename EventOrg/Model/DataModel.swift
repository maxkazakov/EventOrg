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
    static let memberInBillDebtChanged = Notification.Name(rawValue: "MemberInBillDebtChanged")
}

protocol Assignable{
    associatedtype T
    func assign(fromObj obj: T)
}

class Base{
    var id: Int64
    init(id: Int64 = -1){
        self.id = id
    }
    
}

class Event: Base {
    
    var name: String;
    var image: UIImage?
    
    var members = [Member]()
    var bills = [Bill]()
    
    init(id: Int64 = -1, name: String, withPic pic: UIImage? = nil){
        self.name = name
        self.image = pic
        super.init(id: id)        
    }
    
    deinit{
        self.delete()
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

// участников
class Member: Base, Equatable {
    weak var owner: Event!
    
    var membersInBills = NSHashTable<MemberInBill>(options: .weakMemory)
    
    var name: String = ""
    // TODO для исключения человека из тусовки без удаления из списка
    var enabled: Bool = true
    
    init(id: Int64, _ name: String, owner: Event?){
        self.name = name
        self.owner = owner
        super.init(id: id)
    }
       
    convenience init(_ name: String, owner: Event){
        self.init(id: -1, name, owner: owner)
    }
    
    deinit {
        membersInBills.allObjects.forEach({$0.detach()})
        self.delete()
        print("member deleted")
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
}

// мужик в чеке
class MemberInBill: Base, Equatable{
    weak var bill: Bill!
    weak var member: Member!
    
    // Вручную отредактированные не реагируют на изменения других объектов
    var editedManually = false
    public private(set) var debt: Double = 0.0
    
    deinit {
        self.delete()
        print("deinit memberinbill")
    }
    
    func detach(){
        bill.remove(memberInBill: self)
    }
    
    init(id: Int64, debt: Double, manually: Bool, bill: Bill?, member: Member?) {
        super.init(id: id)
        self.bill = bill
        self.member = member
        self.debt = debt
        self.editedManually = manually
    }
    
    convenience init(bill: Bill, member: Member){
        self.init(id: -1, debt: 0.0, manually: false, bill: bill, member: member)
    }
    
    static func == (lhs: MemberInBill, rhs: MemberInBill) -> Bool {
        return lhs === rhs
    }
    
    // withNotifyOther - true только когда значение задается пользователем вручну.
    // пересчитываем долг у других мужиков в чеке + помечаем значние как отредактированное вручную
    func setDebt(_ debt: Double, withNotifyOther: Bool = false){
        if debt > bill.cost{
            self.debt = bill.cost
        }
        else{
            self.debt = debt
        }
        
        if withNotifyOther{
            editedManually = true

            var fixedCost = 0.0
            var otherCount = 0
            
            bill.membersInBills.forEach{
                if $0.editedManually{
                    fixedCost += $0.debt
                }
                else{
                    otherCount += 1
                }
            }
            
            // высчитываем как распределить остаток
            var rest = bill.cost - fixedCost
            if rest < 0 {
                rest = 0.0
            }
            guard otherCount > 0 else{
                return
            }
            rest = rest / Double(otherCount)
            let userInfo = ["debt" : rest]
            NotificationCenter.default.post(name: NotificationTypes.memberInBillDebtChanged, object: self, userInfo: userInfo)
        }
    }
}


class Bill: Base, Equatable, Assignable{
    weak var owner: Event!
    
    typealias T = Bill
    
    func assign(fromObj obj: Bill) {
        membersInBills = obj.membersInBills
        for mem in membersInBills{
            mem.bill = self
        }
        name = obj.name
        images = obj.images
        cost = obj.cost
    }
    
    // Если копия, то при ее удалении не детачим участников в чеке.
    // См. deinit
    var name: String = ""
    var images: [UIImage] = []
    var membersInBills: [MemberInBill] = []
    var cost: Double = 0.0
    
    
    static func == (lhs: Bill, rhs: Bill) -> Bool {
        return lhs === rhs
    }        
    
    init(id: Int64, name: String, cost: Double, owner: Event?){
        super.init(id: id)
        self.name = name
        self.cost = cost
        self.owner = owner
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberInBillDebtChanged), name: NotificationTypes.memberInBillDebtChanged, object: nil)
    }
    
    convenience init(owner: Event?){
        self.init(id: -1, name: "", cost: 0.0, owner: owner)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.delete()
        print("bill deleted")
    }

    
    @objc func onMemberInBillDebtChanged(_ notification: Notification){       
        guard let userInfo = notification.userInfo,
            let debt = userInfo["debt"] as? Double else{
                return
        }
        // меняем долг у всех, кому значение не задавали вручную
        for mem in membersInBills{
            if !mem.editedManually {
                mem.setDebt(debt)
            }
        }
    }
    
    // добавление нового участника в чек
    func append(member: Member){
        let memberInBill = MemberInBill(bill: self, member: member)        
        membersInBills.append(memberInBill)
        member.membersInBills.add(memberInBill)
        memberInBill.save()
    }
    
    func remove(memberInBillAt idx: Int){
        guard idx < membersInBills.count else{
            fatalError()
        }
        let memInBill = membersInBills[idx]
        memInBill.delete()
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
    
    func resetBillMembers(){
        let cnt = membersInBills.count
        guard cnt != 0 else{
            return
        }
        let avgVal = cost / Double(cnt)
        membersInBills.forEach{
            $0.editedManually = false
            $0.setDebt(avgVal)
        }
    }
}



