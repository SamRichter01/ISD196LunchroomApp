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
            
            for item in aLaCarteData {
                /*let index = item.value(forKeyPath: "index") as! String
                let name = item.value(forKeyPath: "name") as! String
                let price = item.value(forKeyPath: "price") as! String
                    
                let newItem = MenuItem(index: index, name: name, price: price)
                aLaCarteItems.append(newItem)*/
                
                let itemName = item.value(forKeyPath: "name") as! String
                previousOrder.append(itemName)
                print(itemName)
            }
            
            if lineData.count > 0 {
                let lineName = lineData[0].value(forKey: "name") as! String
                previousOrder.append(lineName)
            }
            
            print("Data recovered successfully")
            
            if previousOrder.count > 0 {
                print("Previous Order ")
            }
        } catch {
            print("Could not recover data.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
