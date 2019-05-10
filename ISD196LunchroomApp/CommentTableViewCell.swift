//
//  CommentTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 3/6/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

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
