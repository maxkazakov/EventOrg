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
    UITableViewDataSource, UITableViewDelegate{

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
    
    
    var _decimalKeyboard: UIToolbar!
    var decimalKeyboard: UIToolbar!{
        if _decimalKeyboard == nil{
            _decimalKeyboard = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            _decimalKeyboard.barStyle       = UIBarStyle.default
            let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            _decimalKeyboard.items = items
            _decimalKeyboard.sizeToFit()
        }
        return _decimalKeyboard
    }
    
    @IBAction func close(_ sender: Any) {
        if let nc = navigationController{
            nc.popViewController(animated: true)
        }
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
    
    // MARK: - Text field delegate
    
    func doneButtonAction() {
        currentTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === nameTf{
           bill.name = nameTf.text!
           navItem.title = bill.name
        }
        else if textField === costTf{
            bill.cost = 0.0
            if let costval = Double(costTf.text!){
                bill.cost = costval
            }
            membersTable.reloadData()
        }
        updateSaveBtn()
    }
    
    weak var currentTextField: UITextField!
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func updateSaveBtn(){
        saveBtn.isEnabled = nameTf.text != ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        if (bill != nil) {
            updateInfo()
        }
        else{
            bill = Bill()
        }
        
        updateSaveBtn()
        costTf.delegate = self
        nameTf.delegate = self
        photosCV.delegate = self
        photosCV.dataSource = self
        membersTable.delegate = self
        membersTable.dataSource = self
        costTf.inputAccessoryView = decimalKeyboard
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
            cell.debt.inputAccessoryView = decimalKeyboard
            cell.debt.delegate = self
            return cell
    }
    

    
    @IBAction func deleteMember(_ sender: Any) {
        if let idx = membersTable.indexPathForSelectedRow{
            bill.remove(memberInBillAt: idx.row)
            membersTable.deleteRows(at: [idx], with: .automatic)
        }
    }
}
