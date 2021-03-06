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
import Reachability
import CoreData

class FinalizeOrderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var discardOrderButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var orderCollectionView: UICollectionView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var sendOrderButton: UIButton!
    @IBOutlet weak var wifiLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    let network = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyViewLabel.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(itemRemoved),
                                               name: Notification.Name("itemRemoved"), object: nil)
        
        orderCollectionView.delegate = self
        orderCollectionView.dataSource = self
        
        changePrice()
        //totalPriceLabel.text = "$\(totalPrice)"
        // Do any additional setup after loading the view.
        
        // Setting up the database
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        wifiLabel.center.x += view.bounds.width / 2
        
        NetworkManager.isUnreachable { _ in
            DispatchQueue.main.async {
                self.sendOrderButton.isEnabled = false
            }
        }
        
        network.reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                self.sendOrderButton.isEnabled = false
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.wifiLabel.center.x -= self.view.bounds.width / 2
                }, completion: nil)
            }
        }
        
        network.reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                self.sendOrderButton.isEnabled = true
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.wifiLabel.center.x += self.view.bounds.width / 2
                }, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NetworkManager.isUnreachable { _ in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.wifiLabel.center.x -= self.view.bounds.width / 2
                }, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changePrice() {
        totalPriceLabel.text = "Total: $\(String(format: "%.2f", abs(totalPrice)))"
    }
    
    @objc func itemRemoved () {
        orderCollectionView.reloadData()
        changePrice()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section < mealsOrdered.count  {
            
            return mealsOrdered[section].items.count
            
        } else {
            
            return 0
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "menuCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MenuCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
        }
        
        cell.itemLabel.text = mealsOrdered[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return (mealsOrdered.count + itemsOrdered.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewHeader", for: indexPath) as? FinalizeViewCollectionReusableView else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
            
            if indexPath.section < mealsOrdered.count {
                
                header.lineLabel.text = mealsOrdered[indexPath.section].name
                header.priceLabel.text = mealsOrdered[indexPath.section].price
                header.backgroundView.isHidden = true
                
            } else {
                
                header.lineLabel.text = itemsOrdered[indexPath.section - mealsOrdered.count].name
                header.priceLabel.text = itemsOrdered[indexPath.section - mealsOrdered.count].price
                header.backgroundView.isHidden = false
            }
            
            return header
            
        case UICollectionElementKindSectionFooter:
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "menuCollectionViewFooter", for: indexPath)
            
            return footer
            
        default:
            
            let reusableView = UICollectionReusableView()
            return reusableView
        }
    }
    
    @IBAction func discardOrder(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendOrder (_ sender: UIButton) {
        
        if mealsOrdered.count < 1 && itemsOrdered.count < 1 {
            let alertController = UIAlertController(title: "Order incomplete", message:
                "Please order at least one item before sending your order", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        performSegue(withIdentifier: "displaySendPopup", sender: self)
        
        // Add a new document in collection "orders"
        let orderRef = db.collection("orders").document(getDate(format: 0))
            .collection("days").document(getDate(format: 1))
        
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
            
            var totalItems = [String]()
            var tempItems = [String]()
            
            for item in itemsOrdered {
                
                totalItems.append(item.name)
            }
            
            for item in previousItems {
                
                totalItems.append(item.name)
            }
            
            for str in totalItems {
                
                if !tempItems.contains(str) {
                    
                    tempItems.append(str)
                }
            }
            
            totalItems = tempItems
            
            for x in 0..<totalItems.count {
                
                var numberOrdered = 0
                
                for y in 0..<previousItems.count {
                    
                    if previousItems[y].name == totalItems[x] {
                        
                        numberOrdered -= 1
                    }
                }
                
                for y in 0..<itemsOrdered.count {
                    
                    if itemsOrdered[y].name == totalItems[x] {
                        
                        numberOrdered += 1
                    }
                }
                
                if let previousItem = orderDoc.data()?[totalItems[x]] as? Int {
                    
                    if (previousItem + numberOrdered) >= 0 {
                        
                        transaction.updateData([totalItems[x]: previousItem + numberOrdered], forDocument: orderRef)
                        
                    } else {
                        
                        transaction.updateData([totalItems[x]: 0], forDocument: orderRef)
                    }
                    
                } else {
                    
                    if numberOrdered >= 0 {
                        
                        transaction.updateData([totalItems[x]: numberOrdered], forDocument: orderRef)
                        
                    } else {
                        
                        continue
                    }
                }
            }
            
            var totalMeals = [String]()
            var tempMeals = [String]()
            
            for item in mealsOrdered {
                
                totalMeals.append(item.name)
            }
            
            for item in previousMeals {
                
                totalMeals.append(item.name)
            }
            
            for str in totalMeals {
                
                if !tempMeals.contains(str) {
                    
                    tempMeals.append(str)
                }
            }
            
            totalMeals = tempMeals
            
            for x in 0..<totalMeals.count {
                
                var numberOrdered = 0
                
                for y in 0..<previousMeals.count {
                    
                    if previousMeals[y].name == totalMeals[x] {
                        
                        numberOrdered -= 1
                        
                    }
                }
                
                for y in 0..<mealsOrdered.count {
                    
                    if mealsOrdered[y].name == totalMeals[x] {
                        
                        numberOrdered += 1
                        
                    }
                }
                
                if let previousItem = orderDoc.data()?[totalMeals[x]] as? Int {
                    
                    if (previousItem + numberOrdered) >= 0 {
                        
                        transaction.updateData([totalMeals[x]: previousItem + numberOrdered], forDocument: orderRef)
                        
                    } else {
                        
                        transaction.updateData([totalMeals[x]: 0], forDocument: orderRef)
                    }
                    
                } else {
                    
                    if numberOrdered >= 0 {
                        
                        transaction.updateData([totalMeals[x]: numberOrdered], forDocument: orderRef)
                        
                    } else {
                        
                        continue
                    }
                }
            }
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                
                Order.saveOrder()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    NotificationCenter.default.post(name: Notification.Name("orderSent"), object: nil)
                })
            }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let batchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ALaCarteItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: batchRequest)
        let lineBatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LineOrdered")
        let lineDeleteRequest = NSBatchDeleteRequest(fetchRequest: lineBatchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.execute(lineDeleteRequest)
            
            print("Data deleted successfully")
        } catch {
            print("Failed to delete data")
        }
        
        for meal in mealsOrdered {
            
            self.saveLine(label: meal.name, price: meal.price, items: meal.itemsToString())
        }
        
        for item in itemsOrdered {
            self.saveALaCarteItem(label: item.name, cost: item.price)
        }
        
        self.updateOrderDate()
    }
    
    func saveALaCarteItem(label: String, cost: String) {
        //These two lines create a managedContext which stores the data you want to save to CoreData.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //These lines create a name and price managed objects and inserts them into the managed context to be saved to CoreData.
        let entity = NSEntityDescription.entity(forEntityName: "ALaCarteItem", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        object.setValue(label, forKeyPath: "name")
        object.setValue(cost, forKeyPath: "price")
        
        
        //Using the managed objects, this sets the name and price parameters to their respective attributes to be saved.
        
        do {
            //This saves the data in the managed context to CoreData.
            try managedContext.save()
            print("Data saved successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveLine(label: String, price: String, items: String) {
        //These two lines create a managedContext which stores the data you want to save to CoreData.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //These two lines create a managed object and inserts it into the managed context to be saved to CoreData.
        let entity = NSEntityDescription.entity(forEntityName: "LineOrdered", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //Using the managed object, this sets the name parameter to the attribute "name" to be saved.
        object.setValue(label, forKeyPath: "name")
        object.setValue(price, forKeyPath: "price")
        object.setValue(items, forKeyPath: "items")
        
        do {
            //This saves the data in the managed context to CoreData.
            try managedContext.save()
            print("Data saved successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateOrderDate() {
        
        var previousDate: [NSManagedObject] = []
        
        //These two lines create a managedContext which stores the data you want to save to CoreData.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let orderDateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDate")
        
        do {
            
            previousDate = try managedContext.fetch(orderDateRequest) as! [NSManagedObject]
            
            if previousDate.count > 0 {
                
                let oldDate = previousDate[0]
                oldDate.setValue(Date(), forKeyPath: "date")
                
            } else {
                
                let entity = NSEntityDescription.entity(forEntityName: "OrderDate", in: managedContext)!
                let object = NSManagedObject(entity: entity, insertInto: managedContext)
                
                object.setValue(Date(), forKeyPath: "date")
            }
            
            try managedContext.save()
            
            print("Data saved successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getDate(format: Int) -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        var monthName = "September"
        var day = 1
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        monthName = monthToString(month: month)
        
        // If the current date is not a valid school day, this while loop will increment the school day until it finds the next one. If it's december, it sets the month to january. I don't know what would happen if you set the date to after school ended but it might just run forever so that needs to be fixed.
        
        if (hour > 10) {
            
            day += 1
        }
        
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
}
