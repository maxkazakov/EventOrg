//
//  ViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 29/01/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    var events: [Event]!
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        events = DataBase.instance.selectAllEvents();
        
        navItem.leftBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToEventList(sender: UIStoryboardSegue) {
        if let eventViewController = sender.source as? EventViewController
        {
            if let selectedPath = table.indexPathForSelectedRow{
                let event = events[selectedPath.row]
                event.update()
                table.reloadRows(at: [selectedPath], with: .middle)
            }
            else{
                let event: Event! = eventViewController.event
                event.save()
                let newIndexPath = IndexPath(row: events.count, section: 0)
                events.append(event)
                table.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventTableViewCell
        
        let event = events![indexPath.row]
        cell.setEvent(event)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let event = events.remove(at: indexPath.row)
            event.delete()            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "EditEvent"{
            guard let selectedCell = sender as? EventTableViewCell else{
                return
            }
            
            guard let destController = segue.destination as? EventViewController  else {
                return
            }
            
            guard let indexPath = table.indexPath(for: selectedCell) else {
                return
            }
            let selectedEvent = events?[indexPath.row]
            destController.event = selectedEvent!
        }
    }

}

