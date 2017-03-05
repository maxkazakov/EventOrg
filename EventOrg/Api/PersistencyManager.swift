//
//  PersistencyManager.swift
//  EventOrg
//
//  Created by Максим Казаков on 04/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {

    var events: [Event]
   
    
    override init() {
        let event = Event("Mega Super Party", withPic: UIImage(named: "DefaultEventImg"))
        
        event.add(member: Member("qweqw"))
        event.add(member: Member("Alex"))
        event.add(member: Member("max"))
        
        let bill = Bill()
        bill.name = "Drinks"
        bill.cost = 100
        bill.images.append(UIImage(named: "DefaultEventImg")!)
        
        event.add(bill: bill)
        
        events = [event]
    }
    
    func addEvent(_ event: Event){
        events.append(event)
    }
    
    func deleteEvent(_ atIndex: Int){
        events.remove(at: atIndex)
    }
    
    
}
