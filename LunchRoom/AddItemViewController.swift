//
//  AddItemViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/22/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

/*
var selectedName = "Name"
var selectedPrice = "$0.00"
 */

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var matchingItems = [MenuItem]()
    var editingLine = ""
    var editingMonth = ""
    var editingDay = ""
    var itemToAdd = ""
    
    lazy var db = Firestore.firestore()
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var aLaCarteMenuTableView: UITableView!
    @IBOutlet weak var deleteTextButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemDescriptionTextField: UITextField!
    @IBOutlet weak var saveAndUploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        aLaCarteMenuTableView.delegate = self
        aLaCarteMenuTableView.dataSource = self
        
        deleteTextButton.isHidden = true
        
        saveAndUploadButton.isEnabled = false
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addItem(_:)), name: NSNotification.Name(rawValue: "addedItem"), object: nil)
        
        dateLabel.text = "Editing \(editingLine)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToMainMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAndUploadPressed(_ sender: UIButton) {
        
        let itemIndex = menuItems.count
        
        let newItem = MenuItem(name: itemNameTextField.text!, description: "")
        
        monthlyMenus[editingMonth]!.days[Int(editingDay)!]!
            .lines[editingLine]!.items.append(newItem.name)
        
        db.collection("menus").document("Menu Items").collection("Items").document(newItem.name).setData(["Description": itemDescriptionTextField.text!])
        
        let docReference = db.collection("menus").document(editingMonth).collection("days").document(editingDay)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let dbDocument: DocumentSnapshot
            do {
                try dbDocument = transaction.getDocument(docReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldItems = dbDocument.data()?[self.editingLine] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve data from snapshot \(dbDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var newItems = oldItems
            newItems.append(newItem.name)
            
            transaction.updateData([self.editingLine: newItems], forDocument: docReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @IBAction func checkForName(_ sender: UITextField) {
        
        if let _ = itemNameTextField.text {
            
            if let _ = itemDescriptionTextField.text {
                
                saveAndUploadButton.isEnabled = true
                
            } else {
                
                saveAndUploadButton.isEnabled = false
            }
        } else {
            
            saveAndUploadButton.isEnabled = false
        }
    }
    
    @IBAction func checkForDescription(_ sender: UITextField) {
        
        if let _ = itemNameTextField.text {
            
            if let _ = itemDescriptionTextField.text {
                
                saveAndUploadButton.isEnabled = true
                
            } else {
                
                saveAndUploadButton.isEnabled = false
            }
        } else {
            
            saveAndUploadButton.isEnabled = false
        }
    }
    
    @IBAction func searchBarEdited(_ sender: UITextField) {
        aLaCarteMenuTableView.reloadData()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func returnButtonPressed(_ sender: UITextField) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func deleteText(_ sender: UIButton) {
        searchBar.text = ""
        aLaCarteMenuTableView.reloadData()
    }
    
    @objc func addItem (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["itemName"] as? String {
                
                monthlyMenus[editingMonth]!.days[Int(editingDay)!]!
                    .lines[editingLine]!.items.append(str)
                
                let docReference = db.collection("menus").document(editingMonth).collection("days").document(editingDay)
                
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let dbDocument: DocumentSnapshot
                    do {
                        try dbDocument = transaction.getDocument(docReference)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let oldItems = dbDocument.data()?[self.editingLine] as? [String] else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve data from snapshot \(dbDocument)"
                            ]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    var newItems = oldItems
                    newItems.append(str)
                    
                    transaction.updateData([self.editingLine: newItems], forDocument: docReference)
                    return nil
                }) { (object, error) in
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matchingItems = Array(menuItems.values)
        
        if let text = searchBar.text {
            if text.count > 0 {
                for x in stride(from: matchingItems.count - 1, to: -1, by: -1) {
                    
                    let itemName = matchingItems[x].name.lowercased()
                    let key = text.lowercased()
                    
                    if itemName.components(separatedBy: key).count < 2 {
                        matchingItems.remove(at: x)
                    }
                }
            }
        }
        
        if searchBar.text != "" {
            deleteTextButton.isHidden = false
        } else {
            deleteTextButton.isHidden = true
        }
        
        if matchingItems.count >= 1 {
            
            return matchingItems.count
            
        } else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "addItemCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of ALaCarteTableViewCell.")
        }
        
        cell.itemLabel.text = matchingItems[indexPath.row].name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

