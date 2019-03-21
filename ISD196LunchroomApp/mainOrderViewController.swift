//
//  mainOrderViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/13/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class mainOrderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var emptyViewLabel: UILabel!
    
    // The default month and day
    var monthName = "September"
    var day = 1
    
    // An array of keys for the line dictionary, will be explained late
    var todaysLines = [Line]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyViewLabel.isHidden = true
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
    
        let date = Date()
        let calendar = Calendar.current
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
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
        
        dateLabel.text = "\(monthName) \(day), \(year)"
        
        Order.reloadItemCount()
        itemCountLabel.text = "\(itemCount)"
        // Do any additional setup after loading the view.
        
        // Creates a listener to update the item count when a new item is added
        NotificationCenter.default.addObserver(self, selector: #selector(itemOrdered),
            name: Notification.Name("itemOrdered"), object: nil)

        // Sets the lineKeys array to contain all the keys for the lines in the dictionary
        todaysLines = [Line]()
        let tempLineKeys = Array(monthlyMenus[self.monthName]!.days[self.day]!.lines.keys)
        
        for str in linePriorities {
            if tempLineKeys.contains(str) {
                if monthlyMenus[self.monthName]!.days[self.day]!
                    .lines[str]!.items.count > 0 {
                    todaysLines.append(monthlyMenus[self.monthName]!.days[self.day]!.lines[str]!)
                }
            }
        }
    }
    
    @objc func itemOrdered () {
        
        itemCountLabel.text = "\(itemCount)"
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        if mealOrdered.count > 0 || itemsOrdered.count > 0 {
            
            let alertController = UIAlertController(title: "Cancel Order", message: "Are you sure you want to cancel your order?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                Order.deleteOrder()
                self.dismiss(animated: true, completion: nil)}))
        
            self.present(alertController, animated: true, completion: nil)
        
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - collection view data source
    
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

        if  todaysLines.count < 1 {
            
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
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewHeader", for: indexPath) as? OrderCollectionViewReusableView else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
            
            header.lineLabel.text = todaysLines[indexPath.section].name
            header.priceLabel.text = todaysLines[indexPath.section].price
            header.line = todaysLines[indexPath.section]
            
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
    
    @IBAction func finalizeOrderPressed(_ sender: UIButton) {
        if mealOrdered.count < 1 && itemsOrdered.count < 1 {
            let alertController = UIAlertController(title: "Order incomplete", message:
                "Please order at least one item before continuing", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "finalizeOrder1", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
