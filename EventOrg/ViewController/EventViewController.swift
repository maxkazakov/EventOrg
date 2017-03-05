//
//  EventViewController.swift
//  EventOrg
//
//  Created by Максим Казаков on 30/01/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class EventViewController: UITableViewController, UITextFieldDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventNameTf.delegate = self
        
//      Edit mode
        if (event == nil){
            event = Event("", withPic: UIImage(named: "DefaultEventImg"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateInfo()
        updateSaveBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewStyle){
        super.init(style: style)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeView(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode
        {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
        
    }
    
    func updateInfo(){
        let name = event.name
        if name == ""{
            navItem.title = "New event"
        }
        else{
            navItem.title = name
        }
        
        sumCost.text = String(format: POHelper.currencyFormat, event.sumCost)
        
        eventNameTf.text = name
        eventImage.image = event.image
        
        membersHint.text = String(format: "%d members", event.members.count)
        billsHint.text = String(format: "%d bills", event.bills.count)
    }
    
    func updateSaveBtn(){
        saveButton.isEnabled = eventNameTf.text != ""
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var eventNameTf: UITextField!
   
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var membersHint: UILabel!
    
    @IBOutlet weak var billsHint: UILabel!
    
    @IBOutlet weak var sumCost: UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        event.name = eventNameTf.text ?? ""
        navItem.title = event.name
        updateSaveBtn()
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        eventNameTf.resignFirstResponder()
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        guard let selectedImg = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        event.image = selectedImg
        dismiss(animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        let identifier = segue.identifier
        
        
        if identifier == "MemberTableSegue"{
            let destContorller = segue.destination as! MembersTableViewController
            destContorller.event = event
        }
        else if identifier == "BillTableSegue"{
            let destContorller = segue.destination as! BillTableViewController
            destContorller.event = event
        }
        else {
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                return
            }
            
            event.image = eventImage.image
        }
    }
}
