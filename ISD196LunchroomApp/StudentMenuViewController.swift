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
        let lineRequest = NSFetchRequest<NSManagedObject>(entityName: "LineOrdered")
        let aLaCarteRequest = NSFetchRequest<NSManagedObject>(entityName: "ALaCarteItem")
        
        do {
            //Sets the following arrays to the array of ManagedObjects that is fetched from CoreData.
            lineData = try managedContext.fetch(lineRequest)
            aLaCarteData = try managedContext.fetch(aLaCarteRequest)
            let lineName = lineData[0].value(forKeyPath: "name") as? String
            print(lineData[0].value(forKeyPath: "name") as? String)
            print("Data recovered successfully")
        } catch let error as NSError {
            print("Could not recover data. \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
