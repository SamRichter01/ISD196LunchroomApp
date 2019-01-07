//
//  FinalizeOrderViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/3/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class FinalizeOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var discardOrderButton: UIButton!
    @IBOutlet weak var mealCollectionView: UICollectionView!
    @IBOutlet weak var mealPriceLabel: UILabel!
    @IBOutlet weak var mealLineLabel: UILabel!
    @IBOutlet weak var aLaCarteOrderTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
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
        totalPriceLabel.text = "$\(totalPrice)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func itemRemoved () {
        aLaCarteOrderTableView.reloadData()
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
        performSegue(withIdentifier: "discardOrder", sender: self)
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
