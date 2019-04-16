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
        
        //These two lines create a managedContext whcih stores the data you fetch from CoreData.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Creates a fetch request for all entities in CoreData.
        let lineRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LineOrdered")
        let aLaCarteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ALaCarteItem")
        
        do {
            //Sets the following arrays to the array of ManagedObjects that is fetched from CoreData.
            lineData = try managedContext.fetch(lineRequest) as! [NSManagedObject]
            aLaCarteData = try managedContext.fetch(aLaCarteRequest) as! [NSManagedObject]
            
            itemsOrdered = [MenuItem]()
            mealsOrdered = [Line]()
            
            for item in aLaCarteData {
                /*let index = item.value(forKeyPath: "index") as! String
                let name = item.value(forKeyPath: "name") as! String
                let price = item.value(forKeyPath: "price") as! String
                    
                let newItem = MenuItem(index: index, name: name, price: price)
                aLaCarteItems.append(newItem)*/
                
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
                totalPrice += Double(price)!
                
            }
            
            print("Data recovered successfully")
            
            
        } catch {
            
            print("Could not recover data.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
