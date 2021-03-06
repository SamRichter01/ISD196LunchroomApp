//
//  NewLineViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 3/15/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class NewLineViewController: UIViewController {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var lineNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var saveLineButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    lazy var db = Firestore.firestore()
    
    var editingDay = 1
    var editingMonth = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        saveLineButton.isEnabled = false
        
        print(editingMonth)
        print(editingDay)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveLinePressed(_ sender: UIButton) {
        
        if let price = priceTextField.text {
            
            if let name = lineNameTextField.text {
                
                let newLine = Line(name: name, price: String(price))
                
                monthlyMenus[editingMonth]!.days[editingDay]!.lines[newLine.name] = newLine
                
                let newLineRef = db.collection("menus").document(editingMonth)
                    .collection("days").document(String(editingDay))

                if let _ = Double(newLine.price) {
                    
                    newLine.price = "$\(newLine.price)"
                }
                
                newLineRef.updateData([newLine.name : [newLine.name, newLine.price]])
                
                let prioritiesRef = db.collection("basicData").document("lines")
                
                if !linePriorities.contains(newLine.name) {
                    
                    linePriorities.append(newLine.name)
                }
                
                prioritiesRef.updateData(["lineList" : linePriorities])
            
                NotificationCenter.default.post(name: Notification.Name("reloadView"), object: nil)
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func checkForName(_ sender: UITextField) {
        
        if let _ = priceTextField.text {
            
            if let _ = lineNameTextField.text {
                
                saveLineButton.isEnabled = true
                
            } else {
                
                saveLineButton.isEnabled = false
            }
        } else {
            
            saveLineButton.isEnabled = false
        }
    }
    
    @IBAction func checkForPrice(_ sender: UITextField) {
        
        if let _ = priceTextField.text {
            
            if let _ = lineNameTextField.text {
                
                saveLineButton.isEnabled = true
                
            } else {
                
                saveLineButton.isEnabled = false
            }
        } else {
            
            saveLineButton.isEnabled = false
        }
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
