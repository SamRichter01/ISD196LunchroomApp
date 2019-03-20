//
//  LunchMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class LunchMenuViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    
    let monthNames = ["September", "October", "November", "December", "January",
                      "February", "March", "April", "May", "June"]
    
    let textColor = UIColor(red:0.49, green:0.71, blue:0.16, alpha:1.0)
    let textFont = UIFont(name: "OpenSans-Regular", size: 17)
    
    var monthIndex = 0
    var monthName = "September"
    var day = 1
    var dayIndex = 0
    
    var lineName = "Line 1"
    
    var todaysLines = [Line]()
    
    var days = [Int]()
    var dates = Dictionary<String,[Int]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyViewLabel.isHidden = true
        
        let date = Date()
        let calendar = Calendar.current
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.commentPressed(_:)), name: NSNotification.Name(rawValue: "commentPressed"), object: nil)
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
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
        
        datePicker.delegate = self
        datePicker.dataSource = self
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        datePicker.layer.cornerRadius = 15
        
        /*
        datePicker.layer.masksToBounds = false
        datePicker.layer.shadowRadius = 5
        datePicker.layer.shadowOpacity = 0.15
        */
        
        datePicker.selectRow(monthIndex, inComponent: 0, animated: true)
        datePicker.selectRow(dayIndex, inComponent: 1, animated: true)
        
        reloadLines()
    
        // Do any additional setup after loading the view.
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
        if segue.identifier == "commentPopup" {
            let destination = segue.destination as! ItemPopupViewController
            
            destination.lineName = lineName
            destination.day = String(day)
            destination.month = monthName
        }
    }
    
    @IBAction func backToMainMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func commentPressed (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            
            lineName = dict["lineName"] as! String
                
            performSegue(withIdentifier: "commentPopup", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return todaysLines[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "menuCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MenuCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
        }
        
        cell.itemLabel.text = todaysLines[indexPath.section].items[indexPath.row]
        
        return cell
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
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewHeader", for: indexPath) as? MenuCollectionViewReusableView else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
        
            header.lineLabel.text = todaysLines[indexPath.section].name
            header.priceLabel.text = todaysLines[indexPath.section].price
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedName = todaysLines[indexPath.section].items[indexPath.row]
        selectedPrice = ""
        performSegue(withIdentifier: "itemPopup", sender: self)
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
            
        } else if component == 1 {
            
            let days = dates[monthNames[datePicker.selectedRow(inComponent: 0)]]
            
            return NSAttributedString(string: String(days![row]), attributes: [NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.font: textFont])
            
        } else {
            
            return NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.font: textFont])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            datePicker.reloadComponent(1)
        }
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
