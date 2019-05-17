//
//  TableViewCells.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/13/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class EditALaCarteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func removeItemPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("removeItemPressed"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}



class EditItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var deleteItemButton: UIButton!
    @IBOutlet weak var editItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func editItemPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("editItemPressed"), object: nil, userInfo: ["itemName": itemLabel.text!])
        
    }
    
    @IBAction func removeItemPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("deleteItemPressed"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}



class AddItemTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addItemToMenu(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: Notification.Name("addedItem"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}



class ALaCarteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addItemToOrder(_ sender: UIButton) {
        
        let item = MenuItem(name: itemLabel.text!, price: priceLabel.text!)
        itemsOrdered.append(item)
        let price = Double(item.price.dropFirst())
        totalPrice += price!
        
        if itemsOrdered.count > 6 {
            
            let removedName = itemsOrdered[0].name
            
            if let price = Double(itemsOrdered[0].price.dropFirst()) {
                
                totalPrice -= price
            }
            
            itemsOrdered.remove(at: 0)
            
            NotificationCenter.default.post(name: Notification.Name("itemLimitReached"), object: nil, userInfo: ["removedName": removedName])
        }
        
        itemCount = (itemsOrdered.count + mealsOrdered.count)
        
        NotificationCenter.default.post(name: NSNotification.Name("itemOrdered"), object: nil, userInfo: ["item": item.name])
    }
}



class ALaCarteMenuTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}



class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentEmailLabel: UILabel!
    @IBOutlet weak var deleteCommentButton: UIButton!
    
    var documentId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func deleteCommentPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("deleteComment"), object: nil, userInfo: ["documentId": documentId])
    }
}

