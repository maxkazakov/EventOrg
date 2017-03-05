//
//  LibraryAPI.swift
//  EventOrg
//
//  Created by Максим Казаков on 04/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    static let instance = LibraryAPI();
    
    private var persistencyManager: PersistencyManager
    
    override init(){
        persistencyManager = PersistencyManager()
    }
    
    func addEvent(_ event: Event){
        persistencyManager.addEvent(event)
    }
    
    func deleteEvent(_ atIndex: Int){
        persistencyManager.deleteEvent(atIndex)
    }
    
    func getEvents() -> [Event]{
        return persistencyManager.events
    }
}
