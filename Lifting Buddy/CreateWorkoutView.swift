//
//  CreateWorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/11/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class CreateWorkoutView: UIScrollView {
    
    // View properties
    
    var nameEntryField: UITextField?
    
    let viewPadding: CGFloat = 20.0
    
    // View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.niceGray()
        
        // Disable horizontal scrolling
        self.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y), animated: false)
        self.isDirectionalLockEnabled = true
        
        // Current height we append to
        var curHeight: CGFloat = 20
        
        // NAME VIEW
        
        // Containing view for the name entry label and view
        let nameEntryContainingView: UIView = UIView(frame: CGRect(x: 10,
                                                         y: curHeight,
                                                         width: self.frame.width - 20,
                                                         height: 70))
        
        let nameLabel: UILabel = UILabel(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: nameEntryContainingView.frame.width,
                                                       height: 20))
        nameLabel.text = "Name of New Workout"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.niceBlue()
        curHeight += 10
        nameEntryContainingView.addSubview(nameLabel)
        
        // If we can fit the enclosed view width in the view, add it.
        if nameEntryContainingView.frame.width >= 250 {
            // Display in a middle of view with max width of 50
            nameEntryField = UITextField(frame: CGRect(x: (nameEntryContainingView.frame.width - 250) / 2,
                                                       y: 30,
                                                       width: 250,
                                                       height: 40))
        } else { // Otherwise, fit a view that fits.
            nameEntryField = UITextField(frame: CGRect(x: 0,
                                                       y: 30,
                                                       width: nameEntryContainingView.frame.width,
                                                       height: 20))
        }
        
        // View select / deselect events
        nameEntryField?.addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
        nameEntryField?.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        
        // View prettiness
        nameEntryField?.layer.cornerRadius = 5.0
        nameEntryField?.textAlignment = .center
        nameEntryField?.placeholder = "Name of New Workout"
        textfieldDeselected(sender: nameEntryField!)
        
        nameEntryContainingView.addSubview(nameEntryField!)
        
        // Add height of the containing view for name entry + additional padding
        // to prevent overlap in views
        curHeight += nameEntryContainingView.frame.height + viewPadding
        
        self.addSubview(nameEntryContainingView)
        
        let exercises = ExerciseTableView(frame: CGRect(x: 10,
            y: curHeight,
            width: self.frame.width - 20,
            height: self.frame.height - curHeight - 20), style: .plain)
        exercises.backgroundColor = UIColor.niceYellow()
        exercises.dataSource = exercises
        exercises.delegate = exercises
        exercises.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        exercises.data.append("New")
        
        self.addSubview(exercises)
    }
    
    // Event functions
    
    @objc func textfieldSelected(sender: UITextField) {
        sender.backgroundColor = UIColor.niceYellow()
        sender.textColor = UIColor.white
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        sender.backgroundColor = UIColor.white
        sender.textColor = UIColor.black
    }
}
