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
    
    let viewPadding: CGFloat = 20.0
    var nameEntryField: UITextField?
    private var prevDataCount = -1
    private var exerciseTableView: ExerciseTableView?
    private var createWorkoutButton: PrettyButton?
    
    // View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.niceGray()
        
        /*
         * If the view is not yet loaded, load it.
         * -1 notes that the view wasn't loaded.
         */
        if prevDataCount == -1 {
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
            
            self.exerciseTableView = ExerciseTableView(frame: CGRect(x: 10,
                                                                    y: curHeight,
                                                                    width: self.frame.width - 20,
                                                                    height: 0),
                                                                    style: .plain)
            exerciseTableView?.backgroundColor = UIColor.white
            exerciseTableView?.appendDataToTableView(data: "test")
            
            self.createWorkoutButton = PrettyButton()
            // Give it standard default properties
            createWorkoutButton?.setTitle("Create Workout", for: .normal)
            createWorkoutButton?.backgroundColor = UIColor.niceBlue()
            createWorkoutButton?.setOverlayColor(color: UIColor.niceYellow())
            createWorkoutButton?.setOverlayStyle(style: .BLOOM)
            createWorkoutButton?.cornerRadius = 5.0
            
            self.addSubview(createWorkoutButton!)
            self.addSubview(exerciseTableView!)
            
            createWorkoutButton?.translatesAutoresizingMaskIntoConstraints = false
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint(item: createWorkoutButton!,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 200).isActive = true
            NSLayoutConstraint(item: createWorkoutButton!,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1, constant: 50).isActive = true
            
            /*
             * Center on x axis,
             * position createWorkout Button below exerciseTableView
             */
            NSLayoutConstraint(item: exerciseTableView!,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: createWorkoutButton!,
                               attribute: .top,
                               multiplier: 1,
                               constant: -20).isActive = true
            NSLayoutConstraint(item: window!,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: createWorkoutButton!,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0).isActive = true
            
            prevDataCount = exerciseTableView!.data.count
        } else if prevDataCount != exerciseTableView!.data.count { // If tableview was updated
            prevDataCount = (exerciseTableView?.data.count)!
            self.contentSize.height = createWorkoutButton!.frame.maxY + 20
        }
        
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
