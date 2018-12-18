//
//  MenuTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/13/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell, UICollectionViewDataSource {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var menuItemCollectionView: UICollectionView!
    
    var items = [String]()
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "menuItemCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MenuItemCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of MenuTableViewCell.")
        }
        
        cell.itemLabel.text = items[indexPath.row]
        
        return cell
    }
    

}
