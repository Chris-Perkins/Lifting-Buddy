//
//  CreateWorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/11/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class CreateWorkoutView: UIScrollView, CreateExerciseViewDelegate {
    
    // View properties
    
    let viewPadding: CGFloat = 20.0
    
    public var dataDelegate: CreateWorkoutViewDelegate?
    
    // variable stating how many cells are in the exercise table view
    private var prevDataCount = -1
    
    // Exercise name field
    private var nameEntryLabel: UILabel
    private var nameEntryField: UITextField
    // Table holding all of our exercises
    private var exerciseTableView: ExerciseTableView
    private var addExerciseButton: PrettyButton
    // Button to create our workout
    private var createWorkoutButton: PrettyButton
    
    override init(frame: CGRect) {
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        exerciseTableView = ExerciseTableView()
        addExerciseButton = PrettyButton()
        createWorkoutButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryLabel)
        self.addSubview(nameEntryField)
        self.addSubview(addExerciseButton)
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
            
            // MARK: Name Entry Label
            nameEntryLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryLabel,
                                                             height: 20).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryLabel,
                                                            width: self.frame.width - 40).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryLabel,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryLabel,
                                                                belowView: self,
                                                                withPadding: viewPadding).isActive = true
            nameEntryLabel.text = "Name of New Workout"
            nameEntryLabel.setDefaultProperties()
            
            // MARK: Name Entry Field
            nameEntryField.translatesAutoresizingMaskIntoConstraints = false
            nameEntryField.setDefaultProperties()
            nameEntryField.placeholder = "Name of New Workout"
            /*
             * Center in view, place below the above frame, and give height/width of 40
             */
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                             height: 40).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryField,
                                                            width: self.frame.width - 80).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                             belowView: nameEntryLabel,
                                                             withPadding: viewPadding / 2).isActive = true
            
            
            // MARK: Exercise Table View

            exerciseTableView = ExerciseTableView(frame: CGRect(x: 10,
                                                                y: 130,
                                                                width: self.frame.width - 20,
                                                                height: 0),
                                                                style: .plain)
            // Prevent clipping as we can click and drag cells
            exerciseTableView.clipsToBounds = false
            exerciseTableView.isScrollEnabled = false
            exerciseTableView.backgroundColor = UIColor.clear
            
            self.addSubview(exerciseTableView)
            
            // MARK: Add exercise button
            addExerciseButton.setTitle("Add exercise", for: .normal)
            addExerciseButton.setTitleColor(UIColor.niceBlue(), for: .normal)
            addExerciseButton.setTitleColor(UIColor.white, for: .highlighted)
            addExerciseButton.setDefaultProperties()
            addExerciseButton.setOverlayStyle(style: .FADE)
            addExerciseButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            addExerciseButton.setOverlayColor(color: UIColor.niceYellow())
            addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
            // Event press for exercise button
            addExerciseButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: addExerciseButton,
                                                            width: exerciseTableView.frame.width).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: addExerciseButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below exerciseTableView
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: addExerciseButton,
                                                             belowView: exerciseTableView,
                                                             withPadding: 0).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: addExerciseButton,
                                                                            inView: self).isActive = true
            
            // MARK: Create workout button
            // Give it standard default properties
            createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
            createWorkoutButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            createWorkoutButton.setTitle("Create Workout", for: .normal)
            createWorkoutButton.setDefaultProperties()
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: createWorkoutButton,
                                                            width: self.frame.width - 50).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: createWorkoutButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below add exercise button
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: createWorkoutButton,
                                                            belowView: addExerciseButton,
                                                            withPadding: viewPadding * 2).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: createWorkoutButton,
                                                                            inView: self).isActive = true
            
            prevDataCount = exerciseTableView.getData().count
        }
        // We call else if instead of just doing if so that when we come back to this view
        // Otherwise, contentSize does not get properly updated.
        else if prevDataCount != exerciseTableView.getData().count { // If tableview was updated
            prevDataCount = exerciseTableView.getData().count
            self.contentSize.height = createWorkoutButton.frame.maxY + 20
        }
        
    }
    
    // MARK: Event functions
    
    @objc func buttonPressed(sender: PrettyButton) {
        switch (sender) {
        case addExerciseButton:
            // Show new view
            let createExerciseView = CreateExerciseView(frame: CGRect(x: 0,
                                                                      y: -self.frame.height,
                                                                      width: self.frame.width,
                                                                      height: self.frame.height))
            createExerciseView.dataDelegate = self
            self.addSubview(createExerciseView)
            
            UIView.animate(withDuration: 0.5, animations: {
                createExerciseView.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: self.frame.width,
                                                  height: self.frame.height)
            })
            break
        case createWorkoutButton:
            if checkRequirementsFulfilled() {
                // Send info to delegate, animate up then remove self
                let createdWorkout = createWorkoutWithData()
                
                let realm = try! Realm()
                try! realm.write {
                    realm.add(createdWorkout)
                }
                
                self.dataDelegate?.finishedWithWorkout(workout: createdWorkout)
                self.removeSelfNicelyWithAnimation()
            }
            break
        default:
            fatalError("Button pressed was not assigned function")
        }
    }
    
    // MARK: Private functions
    
    private func checkRequirementsFulfilled() -> Bool {
        var fulfilled = true
        
        if nameEntryField.text?.characters.count == 0 {
            nameEntryField.backgroundColor = UIColor.niceRed()
            
            fulfilled = false
        }
        
        return fulfilled
    }
    
    private func createWorkoutWithData() -> Workout {
        let createdWorkout = Workout()
        createdWorkout.setName(name: nameEntryField.text)
        
        for exercise in exerciseTableView.getData() {
            createdWorkout.addExercise(exercise: exercise)
        }
        
        return createdWorkout
    }
    
    // MARK: CreateExerciseView delegate
    func finishedWithExercise(exercise: Exercise) {
        self.exerciseTableView.appendDataToTableView(data: exercise)
    }
}

protocol CreateWorkoutViewDelegate {
    func finishedWithWorkout(workout: Workout)
}
