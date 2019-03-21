//
//  NewSchoolDayViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 3/20/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class NewSchoolDayViewController: UIViewController {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var saveDayButton: UIButton!
    
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
        
        saveDayButton.isEnabled = false
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveDayPressed(_ sender: UIButton) {
        
        if let day = dayTextField.text {
            
            if let month = monthTextField.text {
                
                monthlyMenus[month]!.days[Int(day)!] = Day(day: day)
                
                let newDayRef = db.collection("menus").document(month)
                    .collection("days")
                
                newDayRef.document(day).setData([:])
                
                NotificationCenter.default.post(name: Notification.Name("reloadView"), object: nil)
            }
        }
    }
    
    @IBAction func checkForMonth(_ sender: UITextField) {
        
        if let _ = dayTextField.text {
            
            if let _ = monthTextField.text {
                
                saveDayButton.isEnabled = true
                
            } else {
                
                saveDayButton.isEnabled = false
            }
        } else {
            
            saveDayButton.isEnabled = false
        }
    }
    
    @IBAction func checkForDay(_ sender: UITextField) {
        
        if let _ = dayTextField.text {
            
            if let _ = monthTextField.text {
                
                saveDayButton.isEnabled = true
                
            } else {
                
                saveDayButton.isEnabled = false
            }
        } else {
            
            saveDayButton.isEnabled = false
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
