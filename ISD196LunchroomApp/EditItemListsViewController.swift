//
//  EditItemListsViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/7/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class EditItemListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var matchingItems = [MenuItem]()
    
    var editingType = ""
    var editingName = ""
    
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var aLaCarteMenuTableView: UITableView!
    @IBOutlet weak var deleteTextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyViewLabel.isHidden = true
        
        aLaCarteMenuTableView.delegate = self
        aLaCarteMenuTableView.dataSource = self
        
        deleteTextButton.isHidden = true
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteItem(_:)), name: NSNotification.Name(rawValue: "deleteItemPressed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.editItem(_:)), name: NSNotification.Name(rawValue: "editItemPressed"), object: nil)
        
        if editingType == "aLaCarte" {
            
            titleLabel.text = "Editing A La Carte Items"
            
        } else if editingType == "mainMenu" {
            
            titleLabel.text = "Editing Main Menu Items"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        editingName = ""
        aLaCarteMenuTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let editItemViewController = segue.destination as! EditItemViewController
        
        editItemViewController.editingType = editingType
        editItemViewController.editingName = editingName
    }
    
    @IBAction func returnToMainMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchBarEdited(_ sender: UITextField) {
        aLaCarteMenuTableView.reloadData()
    }
    
    @IBAction func createNewItemPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editItemPressed", sender: nil)
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
    
    @objc func deleteItem (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let itemName = dict["itemName"] as? String {
                
                let alertController = UIAlertController(title: "Delete Item", message: "Are you sure you want to permanently delete \(itemName)?", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
                
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    self.deleteItem(itemName: itemName)}))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func deleteItem (itemName: String) {
        
        if editingType == "aLaCarte" {
            
            aLaCarteItems.removeValue(forKey: itemName)
            
            db.collection("menus").document("A La Carte Items").collection("Items").document(itemName).delete()
            
            aLaCarteMenuTableView.reloadData()
            
        } else if editingType == "mainMenu" {
            
            menuItems.removeValue(forKey: itemName)
            
            db.collection("menus").document("Menu Items").collection("Items").document(itemName).delete()
        
            aLaCarteMenuTableView.reloadData()
        }
    }
    
    @objc func editItem (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let itemName = dict["itemName"] as? String {
                
                editingName = itemName
                
                performSegue(withIdentifier: "editItemPressed", sender: self)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if editingType == "aLaCarte" {
            
            matchingItems = Array(aLaCarteItems.values)
            
        } else if editingType == "mainMenu" {
            
            matchingItems = Array(menuItems.values)
        }
        
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
            
            emptyViewLabel.isHidden = true
            
            return matchingItems.count
            
        } else {
            
            emptyViewLabel.isHidden = false
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "editItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EditItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of EditItemTableViewCell.")
        }
        
        if editingType == "aLaCarte" {
            
            cell.itemLabel.text = matchingItems[indexPath.row].name
            cell.priceLabel.text = matchingItems[indexPath.row].price
            cell.itemDescriptionLabel.text = "No Description Provided"
            
        } else if editingType == "mainMenu" {
            
            cell.itemLabel.text = matchingItems[indexPath.row].name
            cell.priceLabel.text = ""
            cell.itemDescriptionLabel.text = matchingItems[indexPath.row].description
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
