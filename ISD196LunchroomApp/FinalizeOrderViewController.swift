//
//  FinalizeOrderViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/3/19.
//  Copyright © 2019 district196.org. All rights reserved.
//


import UIKit
import FirebaseFirestore
import Firebase

class FinalizeOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var discardOrderButton: UIButton!
    @IBOutlet weak var mealCollectionView: UICollectionView!
    @IBOutlet weak var mealPriceLabel: UILabel!
    @IBOutlet weak var mealLineLabel: UILabel!
    @IBOutlet weak var aLaCarteOrderTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemRemoved),
            name: Notification.Name("itemRemoved"), object: nil)

        aLaCarteOrderTableView.delegate = self
        aLaCarteOrderTableView.dataSource = self
        
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
        
        mealPriceLabel.text = mealPrice
        mealLineLabel.text = mealName
        totalPriceLabel.text = "$\(String(format: "%.2f", totalPrice))"
        //totalPriceLabel.text = "$\(totalPrice)"
        // Do any additional setup after loading the view.
        
        // Setting up the database
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changePrice() {
        totalPriceLabel.text = "$\(String(format: "%.2f", totalPrice))"
    }
    
    @objc func itemRemoved () {
        aLaCarteOrderTableView.reloadData()
        changePrice()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemsOrdered.count)
        return itemsOrdered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ALaCarteOrderTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ALaCarteOrderTableViewCell else {
            fatalError("The dequeued cell is not an instance of ALaCarteOrderTableViewCell.")
        }
        
        print(indexPath.count)
        print(itemsOrdered.count)
        
        if itemsOrdered.count < 1 {
            
            cell.itemLabel.text = "No items ordered"
            cell.priceLabel.text = ""
            
        } else {
            
            cell.priceLabel.text = "\(itemsOrdered[indexPath.row].price)"
            cell.itemLabel.text = itemsOrdered[indexPath.row].name
            cell.cellIndex = indexPath.row
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealOrdered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "menuItemCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MenuItemCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of MenuTableViewCell.")
        }
        
        cell.itemLabel.text = mealOrdered[indexPath.row]
        
        return cell
    }

    @IBAction func discardOrder(_ sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendOrder (_ sender: UIButton) {
        
        performSegue(withIdentifier: "displaySendPopup", sender: self)
        
        // Add a new document in collection "orders"
        let orderRef = db.collection("orders").document(getDate(format: 0))
            .collection("days").document(getDate(format: 1))
        
        print("Previous order before deletion \(previousOrder)")
        if previousOrder.count > 0 {
            
            // Delete the old order
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let orderDeletionDoc: DocumentSnapshot
                do {
                    try orderDeletionDoc = transaction.getDocument(orderRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
            
                for x in 0..<previousOrder.count {
                
                    if let previousItem = orderDeletionDoc.data()?[previousOrder[x]] as? Int {
                        
                        print("Deleting item: \(previousOrder[x])")
                        transaction.updateData([previousOrder[x]: previousItem - 1], forDocument: orderRef)
                    
                    } else {
                    
                        continue
                    }
                }
            
                if let oldOrderCount = orderDeletionDoc.data()?["Order count"] as? Int {
                
                        transaction.updateData(["Order count": oldOrderCount - 1], forDocument: orderRef)
                
                } else {
                
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve order count data from snapshot \(orderDeletionDoc)"])
                    errorPointer?.pointee = error
                }
            
                return nil
            
            }) { (object, error) in
                if let error = error {
                    print("Delete Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }
        }
        
        // Make the new order
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let orderDoc: DocumentSnapshot
            do {
                try orderDoc = transaction.getDocument(orderRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if let oldOrderCount = orderDoc.data()?["Order count"] as? Int {
                
                transaction.updateData(["Order count": oldOrderCount + 1], forDocument: orderRef)
                
            } else {
                
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve order count data from snapshot \(orderDoc)"])
                errorPointer?.pointee = error
            }
            
            print("Items in order before ordering \(itemsOrdered)")
            print("Previous order before ordering \(previousOrder)")
            for x in 0..<itemsOrdered.count {
                
                if let oldItem = orderDoc.data()?[itemsOrdered[x].name] as? Int {
                    
                    transaction.updateData([itemsOrdered[x].name: oldItem + 1], forDocument: orderRef)
                    
                } else {
                    
                    transaction.updateData([itemsOrdered[x].name: 1], forDocument: orderRef)
        
                }
            }
            
            if mealName != "" {
                
                if let oldOrder = orderDoc.data()?[mealName] as? Int {
                
                    transaction.updateData([mealName: oldOrder + 1], forDocument: orderRef)
                
                } else {
                
                    transaction.updateData([mealName: 1], forDocument: orderRef)
 
                }
            }
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Write Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                print("Previous order before resetting \(previousOrder)")
                
                Order.saveOrder()
                
                NotificationCenter.default.post(name: Notification.Name("orderSent"), object: nil)
                
                print("Previous order after resetting \(previousOrder)")
            }
        }
    }
    
    func getDate(format: Int) -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        var monthName = "September"
        var day = 1
        
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        monthName = monthToString(month: month)
        
        while (monthlyMenus[monthName]!.days[day] == nil) {
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
        
        switch format {
            
        case 0:
            return monthName
            
        case 1:
            return "\(day)"
            
        case 2:
            return "\(year)"
            
        default:
            return ""
        }
        
    }
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
