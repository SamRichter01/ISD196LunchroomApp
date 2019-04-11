//
//  EditMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/13/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class EditMenuViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    
    let monthNames = ["September", "October", "November", "December", "January",
                      "February", "March", "April", "May", "June"]
    
    let textColor = UIColor(red:0.49, green:0.71, blue:0.16, alpha:1.0)
    let textFont = UIFont(name: "OpenSans-Regular", size: 17)
    
    var monthIndex = 0
    var monthName = "September"
    var day = 1
    var month = 9
    var dayIndex = 0
    var line = "Line 1"
    
    var todaysLines = [Line]()
    
    var days = [Int]()
    var dates = Dictionary<String,[Int]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyViewLabel.isHidden = true
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        reloadDates()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addItem(_:)), name: NSNotification.Name(rawValue: "addItemPressed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeItem(_:)), name: NSNotification.Name(rawValue: "removeItemPressed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeLine(_:)), name: NSNotification.Name(rawValue: "removeLinePressed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView),
            name: Notification.Name("reloadView"), object: nil)
        
        datePicker.delegate = self
        datePicker.dataSource = self
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        datePicker.selectRow(monthIndex, inComponent: 0, animated: true)
        datePicker.selectRow(dayIndex, inComponent: 1, animated: true)

        reloadLines()
        menuCollectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func reloadDates () {
        
        let date = Date()
        let calendar = Calendar.current
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date)
        month = calendar.component(.month, from: date)
        monthName = monthToString(month: month)
        
        // If the current date is not a valid school day, this while loop will increment the school day until it finds the next one. If it's december, it sets the month to january. I don't know what would happen if you set the date to after school ended but it might just run forever so that needs to be fixed.
        while (monthlyMenus[self.monthName]!.days[self.day] == nil) {
            if (day >= calendar.range(of: .day, in: .month, for: date)!.count) {
                if (month == 12) {
                    monthName = monthToString(month: 1)
                } else {
                    monthName = monthToString(month: month + 1)
                }
                day = 0
            }
            day += 1
        }
        
        for x in 0..<monthNames.count {
            
            for y in 1..<32 {
                
                if (monthlyMenus[monthNames[x]]!.days[y] == nil) {
                    
                    continue
                    
                } else {
                    
                    days.append(y)
                }
            }
            dates[monthNames[x]] = days
            days.removeAll()
        }
        
        for x in 0..<monthNames.count {
            
            if monthNames[x] == monthName {
                
                monthIndex = x
                break
            }
        }
        
        for x in 0..<dates[monthName]!.count {
            
            if dates[monthName]![x] == day {
                
                dayIndex = x
                break
            }
        }
    }
    
    // Just a switch statement that converts the number of the month to the name
    func monthToString (month: Int) -> String {
        
        var monthName = "September"
        
        switch month {
        case 9 :
            monthName = "September"
        case 10 :
            monthName = "October"
        case 11 :
            monthName = "November"
        case 12 :
            monthName = "December"
        case 1 :
            monthName = "January"
        case 2 :
            monthName = "February"
        case 3 :
            monthName = "March"
        case 4 :
            monthName = "April"
        case 5 :
            monthName = "May"
        case 6 :
            monthName = "June"
        default :
            break
        }
        
        return monthName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemPressed" {
            let addItemViewController = segue.destination as! AddItemViewController
            
            let month = monthNames[datePicker.selectedRow(inComponent: 0)]
            let day = dates[month]![datePicker.selectedRow(inComponent: 1)]
            
            addItemViewController.editingLine = line
            addItemViewController.editingMonth = month
            addItemViewController.editingDay = String(day)
            
        } else if segue.identifier == "newLinePressed" {
            
            let newLineViewController = segue.destination as! NewLineViewController
            
            let month = monthNames[datePicker.selectedRow(inComponent: 0)]
            let day = dates[month]![datePicker.selectedRow(inComponent: 1)]
            
            newLineViewController.editingMonth = month
            newLineViewController.editingDay = day
        }
    }
    
    @IBAction func backToMainMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newSchoolDayPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "newSchoolDay", sender: self)
    }
    
    @IBAction func newLinePressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "newLinePressed", sender: self)
    }
    
    @objc func reloadView() {
        
        datePicker.reloadAllComponents()
        reloadLines()
        menuCollectionView.reloadData()
    }
    
    @objc func addItem (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            
            if let str = dict["lineName"] as? String {
                
                line = str
                
                self.performSegue(withIdentifier: "addItemPressed", sender: self)
            }
        }
    }
    
    @IBAction func deleteDayPressed(_ sender: UIButton) {
        
        let dayKey = dates[monthName]![datePicker.selectedRow(inComponent: 1)]
        
        dates[monthName]!.remove(at: datePicker.selectedRow(inComponent: 1))
        
        monthlyMenus[monthName]!.days.removeValue(forKey: dayKey)
        
        db.collection("menus").document(monthName).collection("days")
            .document(String(dayKey))
            .delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
        datePicker.selectRow(datePicker.selectedRow(inComponent: 1) - 1, inComponent: 1, animated: false)
    }
    
    @objc func removeItem (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let itemName = dict["itemName"] as? String {
                
                let items = monthlyMenus[monthName]!.days[Int(day)]!
                    .lines[line]!.items
                
                for x in 0..<items.count {
                    
                    if items[x] == itemName {
                        
                        monthlyMenus[monthName]!.days[Int(day)]!
                            .lines[line]!.items.remove(at: x)
                        
                        break
                    }
                }
                
                let docReference = db.collection("menus").document(monthName).collection("days").document(String(day))
                
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let dbDocument: DocumentSnapshot
                    do {
                        try dbDocument = transaction.getDocument(docReference)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let oldItems = dbDocument.data()?[self.line] as? [String] else {
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
                    
                    for x in 0..<newItems.count {
                        
                        if newItems[x] == itemName {

                            newItems.remove(at: x)
                            
                            break
                        }
                    }

                    transaction.updateData([self.line: newItems], forDocument: docReference)
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
        
        reloadLines()
        menuCollectionView.reloadData()
    }
    
    @objc func removeLine (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let lineName = dict["lineName"] as? String {
                
                //let lines = monthlyMenus[monthName]!.days[Int(day)]!.lines
                
                monthlyMenus[monthName]!.days[Int(day)]!
                    .lines.removeValue(forKey: lineName)
                
                let docReference = db.collection("menus").document(monthName).collection("days").document(String(day))
                
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let dbDocument: DocumentSnapshot
                    do {
                        try dbDocument = transaction.getDocument(docReference)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let oldLines = dbDocument.data() else {
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
                    
                    var newLines = oldLines
                    
                    newLines.removeValue(forKey: lineName)
                    
                    transaction.setData(newLines, forDocument: docReference)
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
        
        reloadLines()
        menuCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (todaysLines[section].items.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.row == (todaysLines[indexPath.section].items.count)) {
            
            let cellIdentifier = "addItemCell"
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? NewItemCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of NewItemCollectionViewCell.")
            }
            
            cell.lineName = todaysLines[indexPath.section].name
            
            return cell
            
        } else {
        
            let cellIdentifier = "menuCollectionViewCell"
        
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? EditMenuCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
        
            cell.itemLabel.text = todaysLines[indexPath.section].items[indexPath.row]
            
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if todaysLines.count < 1 {
            
            emptyViewLabel.isHidden = false
            
        } else {
            
            emptyViewLabel.isHidden = true
        }
        
        return todaysLines.count
    }
    
    /*
     print("Number of lines: \(todaysLines.count)")
     return todaysLines.count
     */
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewHeader", for: indexPath) as? EditMenuCollectionReusableView else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
            
            header.lineLabel.text = todaysLines[indexPath.section].name
            
            return header
            
        case UICollectionElementKindSectionFooter:
            
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewFooter", for: indexPath) as? UICollectionReusableView else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
            
            return footer
            
        default:
            
            let reusableView = UICollectionReusableView()
            return reusableView
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return monthNames.count
        } else {
            
            let days = dates[monthNames[datePicker.selectedRow(inComponent: 0)]]
            return days!.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if component == 0 {
            
            return NSAttributedString(string: monthNames[row], attributes: [NSAttributedStringKey.foregroundColor: textColor])
            
        } else {
            
            let days = dates[monthNames[datePicker.selectedRow(inComponent: 0)]]
    
            var lowRow = row
            
            while lowRow > days!.count - 1 {
                
                lowRow -= 1
            }
            
            return NSAttributedString(string: String(days![lowRow]), attributes: [NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.font: textFont!])
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        reloadDates()
        datePicker.reloadAllComponents()
        reloadLines()
        menuCollectionView.reloadData()
    }
    
    func reloadLines () {
        // Sets the lineKeys array to contain all the keys for the lines in the dictionary
        
        todaysLines = [Line]()
        let month = monthNames[datePicker.selectedRow(inComponent: 0)]
        let day = dates[month]![datePicker.selectedRow(inComponent: 1)]
        
        let tempLineKeys = Array(monthlyMenus[month]!.days[day]!.lines.keys)
        
        for str in linePriorities {
            if tempLineKeys.contains(str) {
                todaysLines.append(monthlyMenus[month]!.days[day]!.lines[str]!)
                print("Line count: \(todaysLines.count)")
            }
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
