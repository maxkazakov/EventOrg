//
//  BillTableViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 19/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class BillTableViewController: UITableViewController{

    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return event.bills.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillTableCell", for: indexPath) as! BillTableViewCell

        
        let bill = event.bills[indexPath.row]
        cell.name.text = bill.name
        cell.cost.text = String(format: POHelper.currencyFormat, bill.cost)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            event.bills.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let billViewController = segue.destination as! BillViewController
        billViewController.allMembers = event.members
        
        if segue.identifier == "EditBillSegue"{
            guard let selIdxPath = tableView.indexPathForSelectedRow else {
                return
            }
            let billOriginal = event.bills[selIdxPath.row]
            let billCopy = Bill(isCopy: true)
            billCopy.assign(fromObj: billOriginal)
            billViewController.bill = billCopy
        }
    }
    
    @IBAction func unwindToBillList(sender: UIStoryboardSegue) {
        guard let vc = sender.source as? BillViewController else {
            return
        }
        if let selectedPath = tableView.indexPathForSelectedRow{
            let bill = event.bills[selectedPath.row]
            bill.assign(fromObj: vc.bill)
            tableView.reloadRows(at: [selectedPath], with: .middle)
        }
        else{
            let idxPath = IndexPath(row: event.bills.count, section: 0)
            event.bills.append(vc.bill)
            tableView.insertRows(at: [idxPath], with: .automatic)
        }
    }
    
    
    
}
