//
//  StudentMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/10/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import CoreData

var lineData: [NSManagedObject] = []
var aLaCarteData: [NSManagedObject] = []
var previousOrderDate: [NSManagedObject] = []

class StudentMenuViewController: UIViewController {
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLoginMenu", sender: self)
    }

    @IBAction func quickOrderPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "quickOrder", sender: self)
    }
    
    @IBAction func aLaCarteMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toALaCarteMenu", sender: self)
    }
    
    @IBAction func lunchMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLunchMenu", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldSignOut = true //App will now sign out user after pressing the Log Out button.
        
        ProfanityFilter.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        
        //These two lines create a managedContext whcih stores the data you fetch from CoreData.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Creates a fetch request for all entities in CoreData.
        let orderDateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDate")
        let lineRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LineOrdered")
        let aLaCarteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ALaCarteItem")
        
        do {
            //Sets the following arrays to the array of ManagedObjects that is fetched from CoreData.
            previousOrderDate = try managedContext.fetch(orderDateRequest) as! [NSManagedObject]
            lineData = try managedContext.fetch(lineRequest) as! [NSManagedObject]
            aLaCarteData = try managedContext.fetch(aLaCarteRequest) as! [NSManagedObject]
            
            if previousOrderDate.count > 0 {
                
                let pastDate = previousOrderDate[0].value(forKeyPath: "date") as! Date
                
                let pastDay = calendar.component(.day, from: pastDate)
                let pastHour = calendar.component(.hour, from: pastDate)
                
                print("Last Order: \(pastDay) \(pastHour)")
                print("Current Order: \(day) \(hour)")
                print(getLast())
                print(getNext())
                
                if ((pastDay == getLast() && pastHour > 10) || (pastDay > getLast()))
                    && ((day == getNext() && hour < 11) || (day < getNext())) {
                    
                    itemsOrdered.removeAll()
                    mealsOrdered.removeAll()
                    previousMeals.removeAll()
                    previousItems.removeAll()
                    totalPrice = 0.0
                    
                    for item in aLaCarteData {
                        
                        let itemName = item.value(forKeyPath: "name") as! String
                        let itemPrice = item.value(forKeyPath: "price") as! String
                        let item = MenuItem(name: itemName, price: itemPrice)
                        
                        previousItems.append(item)
                        itemsOrdered.append(item)
                        var price = item.price
                        price.removeFirst()
                        totalPrice += Double(price)!
                    }
                    
                    for line in lineData {
                        
                        let lineName = line.value(forKeyPath: "name") as! String
                        let linePrice = line.value(forKeyPath: "price") as! String
                        let lineItems = Line.stringToItems(str: line.value(forKeyPath: "items") as! String)
                        
                        let line = Line(name: lineName, price: linePrice)
                        line.items = lineItems
                        
                        previousMeals.append(line)
                        mealsOrdered.append(line)
                        var price = line.price
                        price.removeFirst()
                        if let _ = Double(price) {
                            totalPrice += Double(price)!
                        }
                    }
                    
                    print("Data recovered successfully")
                    
                } else {
                    
                    print("Order reset")
                    
                    Order.resetOrder()
                    
                    return
                    
                }
            }
            
        } catch {
            
            print("Could not recover data.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLast() -> Int {
        
        let date = Date()
        let calendar = Calendar.current
        
        var monthName = "September"
        var day = 1
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date) - 1
        let month = calendar.component(.month, from: date)
        monthName = monthToString(month: month)
        
        while (monthlyMenus[monthName]!.days[day] == nil) {
            if (day <= 0) {
                if (month == 1) {
                    monthName = monthToString(month: 12)
                } else {
                    monthName = monthToString(month: month - 1)
                }
                day = calendar.range(of: .day, in: .month, for: date)!.count
            }
            day -= 1
        }
        
        return day
    }
    
    func getNext() -> Int {
        
        let date = Date()
        let calendar = Calendar.current
        
        var monthName = "September"
        var day = 1
        
        // Gets the currennt date and calls monthToString to convert the integer month to an actual word
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
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
        
        return day
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
