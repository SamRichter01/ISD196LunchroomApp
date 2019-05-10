//
//  EditItemViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/7/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class EditItemViewController: UIViewController {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var saveItemButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priceStepper: UIStepper!
    
    lazy var db = Firestore.firestore()
    
    var previousName = ""
    var editingName = ""
    var editingType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        saveItemButton.isEnabled = false
        
        if editingType == "aLaCarte" {
            
            titleLabel.text = "Edit A La Carte Item"
            
            descriptionTextField.isEnabled = false
            
            if editingName != "" {
                
                itemNameTextField.text = aLaCarteItems[editingName]!.name
                priceTextField.text = aLaCarteItems[editingName]!.price
                
            }
            
        } else if editingType == "mainMenu" {
            
            titleLabel.text = "Edit Menu Item"
            
            priceTextField.isEnabled = false
            priceStepper.isEnabled = false
            
            if editingName != "" {
                
                itemNameTextField.text = menuItems[editingName]!.name
                descriptionTextField.text = menuItems[editingName]!.description
                
            }
        }
        
        previousName = editingName
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveLinePressed(_ sender: UIButton) {
        
        if editingType == "aLaCarte" {
            
            var str = priceTextField.text!
            
            if str.contains("$") {
                
                str.removeFirst()
            }
            
            if let dub = Double(str) {
                
                str = "$\(String(format: "%.2f", dub))"
            }
            
            let newItem = MenuItem(name: itemNameTextField.text!, price: str)
            aLaCarteItems[itemNameTextField.text!] = newItem
            
            db.collection("menus").document("A La Carte Items").collection("Items").document(newItem.name).setData(["Cost": newItem.price], merge: true)
            
            if editingName != "" && itemNameTextField.text != editingName {
                
                aLaCarteItems.removeValue(forKey: editingName)
                aLaCarteMenu.removeValue(forKey: editingName)
                
                aLaCarteMenu[itemNameTextField.text!] = newItem
                
                db.collection("menus").document("A La Carte Menu").collection("Items").document(newItem.name).setData(["Cost": newItem.price], merge: true)
                
                db.collection("menus").document("A La Carte Items").collection("Items").document(editingName).delete()
                
                db.collection("menus").document("A La Carte Menu").collection("Items").document(editingName).delete()
            }
            
        } else if editingType == "mainMenu" {
            
            var desc = ""
            
            if descriptionTextField.text == "" {
                
                desc = "No description provided"
            }
            
            let newItem = MenuItem(name: itemNameTextField.text!, description: desc)
            menuItems[itemNameTextField.text!] = newItem
            
            db.collection("menus").document("Menu Items").collection("Items").document(newItem.name).setData(["Description": newItem.description], merge: true)
            
            if editingName != "" && itemNameTextField.text != editingName {
                
                menuItems.removeValue(forKey: editingName)
                
                db.collection("menus").document("Menu Items").collection("Items").document(editingName).delete()
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("reload"),
                                        object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkForName(_ sender: UITextField) {
        
        if let _ = itemNameTextField.text {
            
            if editingName == "aLaCarte" {
                
                if let _ = priceTextField.text {
                
                    saveItemButton.isEnabled = true
                
                } else {
                
                    saveItemButton.isEnabled = false
            
                }
            } else {
                
                saveItemButton.isEnabled = true
            }
        }
    }
    
    @IBAction func checkForPrice(_ sender: UITextField) {
        
        if let _ = priceTextField.text {
            
            if let _ = itemNameTextField.text {
                
                saveItemButton.isEnabled = true
                
            } else {
                
                saveItemButton.isEnabled = false
            }
        } else {
            
            saveItemButton.isEnabled = false
        }
    }
    
    @IBAction func priceStepperPressed(_ sender: UIStepper) {
        
        var str = priceTextField.text!
        
        if str.contains("$") {
            
            str.removeFirst()
        }
        
        if let dub = Double(str) {
            
            priceStepper.maximumValue = (10.0 - dub)
            priceStepper.minimumValue = (0.25 - dub)
            
            let newPrice = dub + priceStepper.value
            
            priceTextField.text = "$\(String(format: "%.2f", newPrice))"
            
        } else {
            
            priceTextField.text = "$0.25"
        }
        
        priceStepper.value = 0
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
