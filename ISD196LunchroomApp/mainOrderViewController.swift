//
//  mainOrderViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/13/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class mainOrderViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var menuItemCollectionView: UICollectionView!
    
    // The default month and day
    var monthName = "September"
    var day = 1
    
    // An array of keys for the line dictionary, will be explained late
    var todaysLines = [Line]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuTableView.dataSource = self
    
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
        // Do any additional setup after loading the view.
        
        // Sets the lineKeys array to contain all the keys for the lines in the dictionary
        todaysLines = [Line]()
        let tempLineKeys = Array(monthlyMenus[self.monthName]!.days[self.day]!.lines.keys)
        let linePriorities = ["Line 1", "Line 2", "Line 3", "Line 4",
                              "Sides", "Farm 2 School", "Soup Bar"]
        
        for str in linePriorities {
            if tempLineKeys.contains(str) {
                todaysLines.append(monthlyMenus[self.monthName]!.days[self.day]!.lines[str]!)
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
        
        if mealOrdered.count > 0 || itemsOrdered.count > 0 {
            
            let alertController = UIAlertController(title: "Cancel Order", message: "Are you sure you want to cancel your order?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                mealOrdered.removeAll()
                itemsOrdered.removeAll()
                totalPrice = 0
                self.performSegue(withIdentifier: "cancelOrder", sender: self)}))
        
            self.present(alertController, animated: true, completion: nil)
        
        } else {
            
            mealOrdered.removeAll()
            itemsOrdered.removeAll()
            totalPrice = 0
            
            performSegue(withIdentifier: "cancelOrder", sender: self)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Returns the number of keys as the number of lines to create in the view
        return todaysLines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "menuTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MenuTableViewCell else {
            fatalError("The dequeued cell is not an instance of MenuTableViewCell.")
        }
        
        cell.line = todaysLines[indexPath.row]
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    @IBAction func finalizeOrderPressed(_ sender: UIButton) {
        if mealOrdered.count < 1 && itemsOrdered.count < 1 {
            let alertController = UIAlertController(title: "Order incomplete", message:
                "Please order at least one item before continuing", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "finalizeOrder1", sender: self)
            tabIndex = 0
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
