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
    
    var monthName = "September"
    var day = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MasterMenu.downloadALaCarteItems()
        MasterMenu.downloadMenuItems()
        MasterMenu.downloadMonthlyMenus()
        
        menuTableView.dataSource = self
        
        let date = Date()
        let calendar = Calendar.current
        
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        monthName = monthToString(month: month)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "cancelOrder", sender: self)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(self.monthName)")
        //print("\(self.day)")
        return monthlyMenus[self.monthName]!.days[self.day]!.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "menuTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MenuTableViewCell else {
            fatalError("The dequeued cell is not an instance of MenuTableViewCell.")
        }
        
        let todaysLines = monthlyMenus[self.monthName]!.days[self.day]!.lines
        print(todaysLines.count)
    
        cell.priceLabel.text = todaysLines["Line 1"]!.price
        cell.lineNameLabel.text = todaysLines["Line 1"]!.name
        cell.itemOneLabel.text = todaysLines["Line 1"]!.items[0]
        cell.itemTwoLabel.text = todaysLines["Line 1"]!.items[1]
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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
