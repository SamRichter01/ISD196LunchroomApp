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

class NewSchoolDayViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var saveDayButton: UIButton!
    
    lazy var db = Firestore.firestore()
    
    var editingDay = 1
    var editingMonth = ""
    
    var range = [Int]()
    
    var monthNames = ["September", "October", "November", "December", "January", "February", "March", "April", "May", "June"]
    var monthNums = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        datePicker.delegate = self
        datePicker.dataSource = self
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveDayPressed(_ sender: UIButton) {
        
        let day = range[datePicker.selectedRow(inComponent: 1)]
        let month = monthNames[datePicker.selectedRow(inComponent: 0)]
                
        monthlyMenus[month]!.days[day] = Day(day: String(day))
        
        let batch = db.batch()
                
        var newDayRef = db.collection("menus").document(month)
            .collection("days").document(String(day))
        
        batch.setData([:], forDocument: newDayRef)
        
        newDayRef = db.collection("orders").document(month)
            .collection("days").document(String(day))
        
        batch.setData(["Order count": 0], forDocument: newDayRef)
        
        newDayRef = db.collection("feedback").document(month)
            .collection("days").document(String(day))
        
        batch.setData(["Comment count": 0], forDocument: newDayRef)
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("reloadView"), object: nil)
    }
    
    func reloadRange() {
        
        let dateComponents = DateComponents(month: monthNums[datePicker.selectedRow(inComponent: 0)])
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        range = Array(calendar.range(of: .day, in: .month, for: date)!)
        
        for x in stride(from: range.count - 1, to: 0, by: -1) {
            
            if monthlyMenus[monthNames[datePicker.selectedRow(inComponent: 0)]]!.days[range[x]] != nil {
                
                range.remove(at: x)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            
            return monthNames.count
            
        } else {
         
            reloadRange()
            
            return range.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            
            datePicker.reloadAllComponents()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            
            return monthNames[row]
            
        } else {
            
            reloadRange()
            
            return String(range[row])
            
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
