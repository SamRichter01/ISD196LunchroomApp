//
//  ItemPopupViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class ItemPopupViewController: UIViewController {
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var commentTextView: UITextView!
    
    lazy var db = Firestore.firestore()
    
    var month = ""
    var day = ""
    var lineName = ""
    
    let borderColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    let thumbColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        commentView.layer.cornerRadius = 8
        commentView.layer.borderColor = borderColor.cgColor
        commentView.layer.borderWidth = 2.0
        
        ratingSlider.value = 0
        ratingSlider.thumbTintColor = thumbColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        titleLabel.text = "Feedback for \(lineName)"
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newRatingPicked(_ sender: UISlider) {
        
        let colorValue = CGFloat(sender.value / 2)
        
        ratingSlider.thumbTintColor = UIColor(
            red:(0.88 + (0 - colorValue)),
            green:(0.88 + (0 + colorValue)),
            blue:(0.88 - abs(colorValue * 0.5)),
            alpha:1.0)
        
        let step: Float = 1
        
        let roundedValue = round(sender.value / step) * step
        
        sender.value = roundedValue
        
    }
    
    @IBAction func sendFeedbackPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Send Feedback", message:
            "Are you sure you want to send your comment?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)}))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.sendComment()
            self.dismiss(animated: true, completion: nil)}))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendComment () {
        
        let feedbackRef = db.collection("feedback").document(month)
            .collection("days").document(day).collection("comments")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let sentDate = dateFormatter.string(from: date)
        
        var commentText = "No comment"
        if commentTextView.text != "" {
            
            commentText = commentTextView.text
        }
        
        let rating = Int(ratingSlider.value)
        
        let line = lineName
        
        feedbackRef.addDocument(data: ["commentText": commentText, "rating": rating, "line": line, "sentDate": sentDate])
        
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
