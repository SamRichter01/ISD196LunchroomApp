//
//  MenuTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/13/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell, UICollectionViewDataSource {


    
    @IBOutlet weak var addToOrderButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var menuItemCollectionView: UICollectionView!
    
    var line = Line(name: "", price: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        menuItemCollectionView.dataSource = self
        menuItemCollectionView.isScrollEnabled = false

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addToOrderPressed(_ sender: UIButton) {
        self.isSelected = true
        
        if mealName == "" {
            let price = Double(line.price.suffix(4))
            totalPrice += price!
        }
        
        mealName = lineNameLabel.text!
        mealPrice = priceLabel.text!
        mealOrdered = line.items
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        priceLabel.text = line.price
        lineNameLabel.text = line.name
        
        if line.name == "Sides" {
            addToOrderButton.isEnabled = false
        }
        
        return line.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "menuItemCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MenuItemCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of MenuTableViewCell.")
        }
        
        cell.itemLabel.text = line.items[indexPath.row]
        
        return cell
    }

}
