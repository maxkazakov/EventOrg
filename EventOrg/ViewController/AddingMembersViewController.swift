//
//  AddingMembersViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 22/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class AddingMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MemberToggleSelectDelegate
    {

    @IBOutlet weak var tableView: UITableView!
    var members: [Member] = []
    var selectedMembers: [Member] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("deinit AddingMembersViewController")
    }

    @IBAction func close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! CheckMemberTableViewCell
        let member = members[indexPath.row]
        cell.nameTf.text = member.name
        cell.delegate = self
        return cell
    }
    
    func toggleSelect(_ sender: UITableViewCell) {
        guard let checkBtn = sender as? CheckMemberTableViewCell else {
            return
        }
        let idx: Int! = tableView.indexPath(for: sender)?.row
        
        let mem = members[idx]
        if checkBtn.checkBtn.isChecked{
            selectedMembers.append(mem)
        }
        else if let idx = selectedMembers.index(of: mem){
            selectedMembers.remove(at: idx)
        }
    }
}
