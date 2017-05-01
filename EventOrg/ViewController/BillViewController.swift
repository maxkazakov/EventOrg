//
//  BillViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 19/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class BillViewController: UIViewController, UITextFieldDelegate,
    UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITableViewDataSource, UITableViewDelegate, BillMemberViewCellDelegate{

    // При редактировнии здесь лежит копия оригинального экземпляра
    // При создании нового - новый экземпляр, который станет оригинальным
    var bill: Bill!
    
    var allMembers: [Member]!
    
    @IBOutlet weak var photosCV: UICollectionView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var costTf: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var membersTable: UITableView!
    
    weak var currentTextField: UITextField?
    
    
    @IBAction func doneBtnClick(_ sender: UIBarButtonItem) {
//        currentTextField?.resignFirstResponder()
    }
    
    @IBAction func reset(_ sender: Any) {
        bill.resetBillMembers()
        membersTable.reloadData()
    }
    
    deinit {
        print("deinit BillViewController")
    }

    @IBAction func addPhoto(_ sender: Any) {
        photosCV.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func deletePhoto(_ sender: Any) {
        if let pathArr = photosCV.indexPathsForSelectedItems{
            guard pathArr.count > 0 else {
                return
            }
            let idx = pathArr[0]
            bill.images.remove(at: idx.row)
            photosCV.deleteItems(at: [idx])
        }
    }
    
    // MARK: - BillMemberViewCellDelegate
    func onDebtChanged(_ cell: BillMemberViewCell, debt value: Double) {
        guard let path = membersTable.indexPath(for: cell) else{
            fatalError("onDebtChanged bad cell")
        }
        let billMem = bill.membersInBills[path.row]        
        billMem.setDebt(value, withNotifyOther: true)
        billMem.update()
        membersTable.reloadData()
    }
    
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === nameTf{
           bill.name = nameTf.text!
           navItem.title = bill.name
           updateSaveBtn()
        }
        else if textField === costTf{            
            if let costval = Double(costTf.text!){
                bill.cost = costval
            }
            membersTable.reloadData()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === costTf{
            textField.setDecimalKeyboard()
        }
        currentTextField = textField
        return true
    }
    
    func updateSaveBtn(){
        saveBtn.isEnabled = nameTf.text != ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
               
        updateInfo()
        
        updateSaveBtn()
        costTf.delegate = self
        nameTf.delegate = self
        
        photosCV.delegate = self
        photosCV.dataSource = self
        
        membersTable.delegate = self
        membersTable.dataSource = self
    }
   
    func updateInfo(){
        navItem.title = bill.name
        nameTf.text = bill.name
        costTf.text = String(format: POHelper.currencyFormat, bill.cost)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bill.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCV.dequeueReusableCell(withReuseIdentifier: "BillImageCell", for: indexPath) as! BillImageCollectionViewCell
        let idx = indexPath.row
        cell.setImage(bill.images[idx])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BillImageCollectionViewCell
        cell.setSelectedBorder()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BillImageCollectionViewCell
        cell.setDefaultBorder()
    }
    // MARK: - ImagePicker Delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        guard let selectedImg = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let idxPath = IndexPath(row: bill.images.count, section: 0)
        bill.images.append(selectedImg)
        dismiss(animated: true, completion: nil)
        photosCV.insertItems(at: [idxPath])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segIdent = segue.identifier
        
        if segIdent == "AddMemberToBillSegue"{
            let dest = segue.destination as! AddingMembersViewController
            let members = bill.getMembers()
            
            for mem in allMembers{
                if !members.contains(mem){
                    dest.members.append(mem)
                }
            }
        }
        else{
            currentTextField?.resignFirstResponder()
        }
    }
    
    @IBAction func unwindFromAddingMembers(sender: UIStoryboardSegue){
        let srcVc = sender.source as! AddingMembersViewController
        for mem in srcVc.selectedMembers{
            bill.append(member: mem)
        }
        membersTable.reloadData()
    }
    
    // MARK: - TableView Delegate - memberTable
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            return bill.membersInBills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BillMemberCell", for: indexPath) as! BillMemberViewCell
            let memberInBill = bill.membersInBills[indexPath.row]
            cell.name.text = memberInBill.member.name
            cell.debt.text = String(format: POHelper.currencyFormat, memberInBill.debt)
            cell.delegate = self
            cell.setManuallyImageHidden(!memberInBill.editedManually)
            return cell
    }
    
    @IBAction func deleteMember(_ sender: Any) {
        if let idx = membersTable.indexPathForSelectedRow{
            bill.remove(memberInBillAt: idx.row)
            membersTable.deleteRows(at: [idx], with: .automatic)
        }
    }
}
