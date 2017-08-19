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
    // variable stating how many cells are in the exercise table view
    private var prevDataCount = -1
    
    // Exercise name field
    private var nameEntryContainerView: UIView
    private var nameEntryLabel: UILabel
    private var nameEntryField: UITextField
    // Table holding all of our exercises
    private var exerciseTableView: ExerciseTableView?
    // Button to create our workout
    private var createWorkoutButton: PrettyButton
    
    override init(frame: CGRect) {
        nameEntryContainerView = UIView()
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        createWorkoutButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryContainerView)
        nameEntryContainerView.addSubview(nameEntryLabel)
        nameEntryContainerView.addSubview(nameEntryField)
        self.addSubview(createWorkoutButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.niceGray()
        
        /*
         * If the view is not yet loaded, load it.
         * -1 notes that the view wasn't loaded.
         */
        if prevDataCount == -1 {
            
            // Containing view for the name entry label and view
            let nameEntryContainingView: UIView = UIView(frame: CGRect(x: 10,
                                                                       y: viewPadding,
                                                                       width: self.frame.width - 20,
                                                                       height: 70))
            self.addSubview(nameEntryContainingView)
            
            // MARK: Name Entry Label
            nameEntryContainingView.addSubview(nameEntryLabel)
            nameEntryLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryLabel,
                                                             height: 20).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryLabel,
                                                            width: nameEntryContainingView.frame.width).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryLabel,
                                                                            inView: nameEntryContainingView).isActive = true
            NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryLabel,
                                                                belowView: nameEntryContainingView,
                                                                withPadding: 0).isActive = true
            nameEntryLabel.text = "Name of New Workout"
            nameEntryLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
            nameEntryLabel.textAlignment = .center
            nameEntryLabel.textColor = UIColor.niceBlue()
            
            // MARK: Name Entry Field
            nameEntryContainingView.addSubview(nameEntryField)
            nameEntryField.translatesAutoresizingMaskIntoConstraints = false
            
            /*
             * Center in view, place below the above frame, and give height/width of 40
             */
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                             height: 40).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryField,
                                                            width: nameEntryContainingView.frame.width - 40).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                            inView: nameEntryContainingView).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                             belowView: nameEntryLabel,
                                                             withPadding: viewPadding / 2).isActive = true
            
            // View select / deselect events
            nameEntryField.addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
            nameEntryField.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
            
            // View prettiness
            nameEntryField.layer.cornerRadius = 5.0
            nameEntryField.textAlignment = .center
            nameEntryField.placeholder = "Name of New Workout"
            textfieldDeselected(sender: nameEntryField)

            self.exerciseTableView = ExerciseTableView(frame: CGRect(x: 10,
                                                                    y: 110,
                                                                    width: self.frame.width - 20,
                                                                    height: 0),
                                                                    style: .plain)
            exerciseTableView?.backgroundColor = UIColor.white
            exerciseTableView?.appendDataToTableView(data: "test")
            
            // Give it standard default properties
            createWorkoutButton.setTitle("Create Workout", for: .normal)
            createWorkoutButton.backgroundColor = UIColor.niceBlue()
            createWorkoutButton.setOverlayColor(color: UIColor.niceYellow())
            createWorkoutButton.setOverlayStyle(style: .BLOOM)
            createWorkoutButton.cornerRadius = 5.0
            
            self.addSubview(exerciseTableView!)
            
            createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: createWorkoutButton, width: 200).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: createWorkoutButton, height: 50).isActive = true
            
            /*
             * Center on x axis,
             * position createWorkout Button below exerciseTableView
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: createWorkoutButton,
                                                            belowView: exerciseTableView!,
                                                            withPadding: 20).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: createWorkoutButton,
                                                                            inView: window!).isActive = true
            
            prevDataCount = exerciseTableView!.getData().count
        } else if prevDataCount != exerciseTableView!.getData().count { // If tableview was updated
            prevDataCount = (exerciseTableView?.getData().count)!
            self.contentSize.height = createWorkoutButton.frame.maxY + 20
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
