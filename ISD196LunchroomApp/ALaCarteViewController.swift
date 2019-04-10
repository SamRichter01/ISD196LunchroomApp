//
//  ALaCarteViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/17/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class ALaCarteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var finalizeOrderButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var aLaCarteTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var deleteTextButton: UIButton!
    
    var monthName = "September"
    var day = 1
    var matchingItems = [MenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyViewLabel.isHidden = true
        
        aLaCarteTableView.delegate = self
        aLaCarteTableView.dataSource = self
        
        deleteTextButton.isHidden = true
        
        //Because A La Carte menus don't change, the date is only used to display at the top of the screen
        let date = Date()
        let calendar = Calendar.current
        
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        monthName = monthToString(month: month)
        
        dateLabel.text = "\(monthName) \(day), \(year)"
        
        Order.reloadItemCount()
        itemCountLabel.text = "\(itemCount)"
        // Do any additional setup after loading the view.
        
        // Creates a listener to update the item count when a new item is added
        NotificationCenter.default.addObserver(self, selector: #selector(itemOrdered),
            name: Notification.Name("itemOrdered"), object: nil)
    }

    @objc func itemOrdered () {
        
        itemCountLabel.text = "\(itemCount)"
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
        
        if mealsOrdered.count > 0 || itemsOrdered.count > 0 {
            
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
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func deleteText(_ sender: UIButton) {
        searchBar.text = ""
        aLaCarteTableView.reloadData()
    }
    
    @IBAction func finalizeOrderPressed(_ sender: UIButton) {
        if mealsOrdered.count < 1 && itemsOrdered.count < 1 {
            let alertController = UIAlertController(title: "LunchRoom", message:
                "Please order at least one item", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            performSegue(withIdentifier: "finalizeOrder2", sender: self)
        }
    }
    
    @IBAction func searchBarEdited(_ sender: UITextField) {
        aLaCarteTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(self.monthName)")
        //print("\(self.day)")
        matchingItems = Array(aLaCarteItems.values)
        if let text = searchBar.text {
            if text.count > 0 {
                for x in stride(from: matchingItems.count - 1, to: -1, by: -1) {
                    
                    let itemName = matchingItems[x].name.lowercased()
                    let key = text.lowercased()
                    
                    if itemName.components(separatedBy: key).count < 2 {
                        matchingItems.remove(at: x)
                    }
                }
            }
        }
        
        if searchBar.text != "" {
            deleteTextButton.isHidden = false
        } else {
            deleteTextButton.isHidden = true
        }
        
        if matchingItems.count >= 1 {
            
            emptyViewLabel.isHidden = true
            
            return matchingItems.count
            
        } else {
            
            emptyViewLabel.isHidden = false
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ALaCarteTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ALaCarteTableViewCell else {
            fatalError("The dequeued cell is not an instance of ALaCarteTableViewCell.")
        }
        
        cell.priceLabel.text = "\(matchingItems[indexPath.row].price)"
        cell.itemLabel.text = matchingItems[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        aLaCarteTableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        selectedName = matchingItems[indexPath.row].name
        selectedPrice = matchingItems[indexPath.row].price
        performSegue(withIdentifier: "itemPopup", sender: self)
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
