//
//  MemberTableViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 01/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit
import ContactsUI

class MembersTableViewController: UITableViewController, CNContactPickerDelegate,
    UINavigationControllerDelegate, MemberTableViewCellDelegate{
    
    var event: Event!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateMemberEnabled(sender: MemberTableViewCell){
        let id = table.indexPath(for: sender)?.row
        event.members[id!].enabled = sender.memberEnabled.isOn
        table.reloadData()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.delegate = self
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
        return event.members.count
    }
    
    
    @IBAction func addMember(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Adding type", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let AddFromContactAction = UIAlertAction(title: "Add from contact", style: .default){
            action in
                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = self
                self.present(contactPicker, animated: true, completion: nil)
            
        }
        alertController.addAction(AddFromContactAction)
        
//        let AddAction = UIAlertAction(title: "Add", style: .default)
//        alertController.addAction(AddAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        for contact in contacts{
            let newIndexPath = IndexPath(row: event.members.count, section: 0)
            let member = Member(CNContactFormatter.string(from: contact, style: .fullName)!, owner: event)
            
            event.add(member: member)
            member.save()
            
            table.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    @IBOutlet var table: UITableView!
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableCell", for: indexPath) as! MemberTableViewCell
        cell.delegate = self
        setData(toCell: cell, fromMember: event.members[indexPath.row])
        return cell
    }
    
    func setData(toCell cell: MemberTableViewCell, fromMember member: Member){
        cell.setName(member.name)
        cell.setEnabled(member.enabled)
        cell.setDbt(member.debt)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            event.remove(memberAt: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

}
