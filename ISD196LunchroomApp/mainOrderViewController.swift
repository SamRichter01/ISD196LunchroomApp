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
    @IBOutlet weak var itemAddedLabel: UILabel!
    
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
        let hour = calendar.component(.hour, from: date)
        monthName = monthToString(month: month)
        
        let bounds: CGRect = itemAddedLabel.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        itemAddedLabel.layer.mask = maskLayer
        
        itemAddedLabel.center.y -= itemAddedLabel.bounds.height
        
        // If the current date is not a valid school day, this while loop will increment the school day until it finds the next one. If it's december, it sets the month to january. I don't know what would happen if you set the date to after school ended but it might just run forever so that needs to be fixed.
        
        if (hour > 10) {
            
            day += 1
        }
        
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
        
        
        dateLabel.text = "My order for \(monthName) \(day)"
        
        itemCount = (itemsOrdered.count + mealsOrdered.count)
        itemCountLabel.text = "\(itemCount)"
        // Do any additional setup after loading the view.
        
        // Creates a listener to update the item count when a new item is added
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.lineOrdered(_:)), name: NSNotification.Name(rawValue: "lineOrdered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(limitReached),
            name: Notification.Name("mealLimitReached"), object: nil)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        itemCountLabel.text = "\(itemCount)"
    }
    
    @objc func lineOrdered (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let meal = dict["line"] as? Line {
                
                var str = ""
                for x in 0..<meal.items.count {
                    
                    if x < meal.items.count - 1 {
                        
                        str.append("\(meal.items[x].dropLast()), ")
                        
                    } else {
                        
                        str.append("\(meal.items[x].dropLast())")
                    }
                }
        
                itemAddedLabel.text = "Added \(meal.name): \(str) to order"
                itemCountLabel.text = "\(itemCount)"
        
                self.view.layer.removeAllAnimations()
            
                UIView.animateKeyframes(withDuration: 2.5, delay: 0.0, options: [], animations: {
                
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1/2.2, animations: {
                        self.itemAddedLabel.center.y += self.itemAddedLabel.bounds.height})
                
                    UIView.addKeyframe(withRelativeStartTime: 2.1/2.2, relativeDuration: 0.1/2.2, animations: {
                            self.itemAddedLabel.center.y -= self.itemAddedLabel.bounds.height})
                
                }, completion: nil)
            }
        }
    }
    
    @objc func limitReached (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["removedName"] as? String {
                
                let alertController = UIAlertController(title: "Meal Limit Reached", message: "Exceeded meal limit of 3, removed \(str) from your order to make room", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        if mealsOrdered.count > 0 || itemsOrdered.count > 0 {
            
            let alertController = UIAlertController(title: "Return to menu", message: "Your changes will not be saved, continue to the main menu?", preferredStyle: UIAlertControllerStyle.alert)
            
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
        if mealsOrdered.count < 1 && itemsOrdered.count < 1 {
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


