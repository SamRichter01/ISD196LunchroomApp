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
    @IBOutlet weak var itemAddedLabel: UILabel!
    
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
        
        Order.reloadItemCount()
        itemCountLabel.text = "\(itemCount)"
        // Do any additional setup after loading the view.
        
        // Creates a listener to update the item count when a new item is added
        NotificationCenter.default.addObserver(self, selector: #selector(itemOrdered),
            name: Notification.Name("itemOrdered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(limitReached),
            name: Notification.Name("itemLimitReached"), object: nil)
    }

    @objc func itemOrdered () {
        
        itemCountLabel.text = "\(itemCount)"
        
        self.view.layer.removeAllAnimations()
        
        UIView.animateKeyframes(withDuration: 2.2, delay: 0.0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1/2.2, animations: {
                self.itemAddedLabel.center.y += self.itemAddedLabel.bounds.height
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2.1/2.2, relativeDuration: 0.1/2.2, animations: {
                self.itemAddedLabel.center.y -= self.itemAddedLabel.bounds.height
            })
            
        }, completion: nil)
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
    
    @objc func limitReached (_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["removedName"] as? String {
                
                let alertController = UIAlertController(title: "Item Limit Reached", message: "Exceeded item limit of 6, \(str) has been removed from order", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
        matchingItems = Array(aLaCarteMenu.values)
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
