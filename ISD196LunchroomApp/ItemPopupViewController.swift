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
import GoogleSignIn

class ItemPopupViewController: UIViewController {
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var nameSwitch: UISwitch!
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
        
        titleLabel.text = "Feedback for \(lineName)"

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
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newRatingPicked(_ sender: UISlider) {
        
        let colorValue = CGFloat(ratingSlider.value / 2)
        
        let red = (0.88 - (0.195 * colorValue) - (0.335 * (colorValue * colorValue)))
        let green = (0.88 + (0.3 * colorValue) - (0.5 * (colorValue * colorValue)))
        let blue = (0.88 + (0.03 * colorValue) - (0.75 * (colorValue * colorValue)))
        
        ratingSlider.thumbTintColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        /*
        let colorValue = CGFloat(sender.value / 4)
        
        ratingSlider.thumbTintColor = UIColor(
            red:(0.88 * (1 - colorValue)),
            green:(0.88 * (1 + colorValue)),
            blue:(0.88 - abs(colorValue)),
            alpha:1.0)
        */
        
        let step: Float = 1
        
        let roundedValue = round(sender.value / step) * step
        
        sender.value = roundedValue
        
    }
    
    @IBAction func sendFeedbackPressed(_ sender: UIButton) {
        
        if commentTextView.text.count > 140 {
            
            let alertController = UIAlertController(title: "Character limit exceeded", message:
                "Can't send comment, text exceeds the 140 character limit.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let alertController = UIAlertController(title: "Send Feedback", message:
            "Are you sure you want to send your comment?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: { (action: UIAlertAction!) in
            return}))
        
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
        dateFormatter.dateFormat = "MMM d, yyyy"
        let sentDate = dateFormatter.string(from: date)
        
        var commentText = "No comment"
        if commentTextView.text != "" {
            
            commentText = commentTextView.text
            
            commentText = ProfanityFilter.removeProfanity(str: commentText)
            
            print(commentText)
        }
        
        let rating = Int(ratingSlider.value)
        
        let line = lineName
        
        var studentName = "Anonymous"
        if nameSwitch.isOn {
            
            studentName = GIDSignIn.sharedInstance()!.currentUser.profile.name
        }
        
        let studentEmail = GIDSignIn.sharedInstance()!.currentUser.profile.email
        
        feedbackRef.addDocument(data: ["commentText": commentText, "rating": rating, "line": line, "sentDate": sentDate, "studentName": studentName, "email": studentEmail])
        
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
