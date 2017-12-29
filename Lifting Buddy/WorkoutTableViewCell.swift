//
//  WorkoutTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CDAlertView

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    public static let heightPerExercise: CGFloat = 40.0
    
    // The workout associated with each cell
    private var workout: Workout?
    
    // The title for every cell
    private let cellTitle: UILabel
    // The fire image displayed by streak
    private let fireImage: UIImageView
    // The label saying how many days we're on streak
    private let streakLabel: UILabel
    // An indicator on whether or not the cell is expanded
    private let expandImage: UIImageView
    // The labels for every exercise
    private var exerciseLabels: [LabelWithPrettyButtonView]
    
    // A delegate to show a view for us
    public var showViewDelegate: ShowViewDelegate?
    // A delegate to display an exercise in the tableview
    public var exerciseDisplayer: ExerciseDisplayer?
    
    // The button stating whether or not we want to edit this workout
    private var editButton: PrettyButton?
    // A button to start the workout
    private var startWorkoutButton: PrettyButton?
    // The exercises this cell has
    private var exercises = List<Exercise>()
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        fireImage = UIImageView(image: #imageLiteral(resourceName: "Fire"))
        streakLabel = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        exerciseLabels = [LabelWithPrettyButtonView]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(cellTitle)
        addSubview(fireImage)
        addSubview(streakLabel)
        addSubview(expandImage)
        
        createAndActivateCellTitleConstraints()
        createAndActivateExpandImageConstraints()
        createAndActivateStreakLabelConstraints()
        createAndActivateFireImageConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        
        cellTitle.textColor = .niceBlue
        cellTitle.textAlignment = .left
        
        // Don't show the streak if there is no streak
        if workout != nil && workout!.getCurSteak() > 0 {
            streakLabel.text = String(describing: workout!.getCurSteak())
            streakLabel.textColor = .niceRed
            
            streakLabel.alpha = 1
            fireImage.alpha = 1
        } else {
            streakLabel.alpha = 0
            fireImage.alpha = 0
        }
        
        // Only layout if selected as they won't be visible
        if isSelected {
            editButton?.setDefaultProperties()
            editButton?.backgroundColor =
                (workout?.canModifyCoreProperties ?? true) ? .niceBlue : .niceLightBlue
            editButton?.setTitle("Edit", for: .normal)
            
            startWorkoutButton?.setDefaultProperties()
            startWorkoutButton?.setTitle("Start Workout", for: .normal)
        }
        
        // If the last time we did this workout was today...
        if let dateLastDone = workout?.getDateLastDone(),
            Calendar.current.isDateInToday(dateLastDone) {
            
            backgroundColor = .niceGreen
            
            cellTitle.textColor = .white
            streakLabel.textColor = .white
            
            if (isSelected) {
                for exerciseLabel in exerciseLabels {
                    exerciseLabel.label.textColor = .white
                }
            }
        } else if workout?.isRepeatedToday == true {
            backgroundColor = .niceLightRed
            
            cellTitle.textColor = .white
            streakLabel.textColor = .white
            if (isSelected) {
                for exerciseLabel in exerciseLabels {
                    exerciseLabel.label.textColor = .white
                }
                
            }
        } else {
            cellTitle.textColor = .niceBlue
            
            if (isSelected) {
                // Only set the color if labels visible. :)
                for exerciseLabel in exerciseLabels {
                    exerciseLabel.label.textColor = .niceBlue
                }
                
                backgroundColor = .niceLightGray
            } else {
                backgroundColor = .white
            }
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set the workout for this cell
    public func setWorkout(workout: Workout) {
        // Only make changes if we need to.
        // TODO: Determine when a change is made so we don't have to be dumb in checking.
        //if workout != workout {
        cellTitle.text = workout.getName()
        
        self.workout = workout
        
        for label in exerciseLabels {
            label.removeFromSuperview()
        }
        exerciseLabels.removeAll()
        editButton?.removeFromSuperview()
        startWorkoutButton?.removeFromSuperview()
        
        editButton = PrettyButton()
        startWorkoutButton = PrettyButton()
        
        editButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        startWorkoutButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        addSubview(editButton!)
        addSubview(startWorkoutButton!)
        
        // Previous view
        var prevLabel: UIView = cellTitle
        
        exercises = workout.getExercises()
        for (index, exercise) in exercises.enumerated() {
            let exerciseView = LabelWithPrettyButtonView()
            
            exerciseView.label.text = exercise.getName()!
            exerciseView.label.textColor = .niceBlue
            exerciseView.label.textAlignment = .left
            exerciseView.label.backgroundColor =
                UIColor.niceGray.withAlphaComponent(index & 1 == 1 ? 0.5 : 0.25)
            
            exerciseView.button.setDefaultProperties()
            exerciseView.button.setTitle("View", for: .normal)
            exerciseView.button.tag = index
            exerciseView.button.addTarget(self,
                                          action: #selector(labelButtonPress(sender:)),
                                          for: .touchUpInside)
            
            addSubview(exerciseView)
            
            // Constraints for this exercise label.
            // Place 10 from left/right of the cell
            // Place 10 below above view, height of 20
            
            exerciseView.translatesAutoresizingMaskIntoConstraints = false
            
            
            NSLayoutConstraint.createViewBelowViewConstraint(view: exerciseView,
                                                             belowView: prevLabel).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseView,
                                                                 withCopyView: self,
                                                                 attribute: .left,
                                                                 plusConstant: 20).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseView,
                                                                 withCopyView: self,
                                                                 attribute: .right,
                                                                 plusConstant: -20).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: exerciseView,
                                                             height: WorkoutTableViewCell.heightPerExercise
                                                            ).isActive = true
            
            exerciseLabels.append(exerciseView)
            prevLabel = exerciseView
        }
        
        // MARK: Edit Button Constraints
        editButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: editButton!,
                                                         belowView: prevLabel,
                                                         withPadding: prevLabel == cellTitle ?
                                                            0 : 26).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editButton!,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton!,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton!,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
        
        
        // MARK: Start workout button constraints
        
        startWorkoutButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: startWorkoutButton!,
                                                         belowView: prevLabel,
                                                         withPadding: prevLabel == cellTitle ?
                                                            0 : 26).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: startWorkoutButton!,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startWorkoutButton!,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startWorkoutButton!,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // Returns this workout
    public func getWorkout() -> Workout? {
        return workout
    }
    
    // Mark: view functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        expandImage.transform = CGAffineTransform(scaleX: 1, y: isSelected ? -1 : 1)
        
        layoutIfNeeded()
    }
    
    // MARK: Event functions
    
    @objc func labelButtonPress(sender: PrettyButton) {
        guard let exercise = workout?.getExercises()[sender.tag] else {
            fatalError("Workout either nil or exercise out of bounds!")
        }
        
        exerciseDisplayer?.displayExercise(exercise)
    }
    
    // Notified on a button press
    @objc func buttonPress(sender: UIButton) {
        switch(sender) {
        case startWorkoutButton!:
            guard let mainViewController = viewController() as? MainViewController else {
                fatalError("view controller is now main view controller?")
            }
            mainViewController.startSession(workout: workout, exercise: nil)
        case editButton!:
            if workout?.canModifyCoreProperties ?? true {
                let createWorkoutView = CreateWorkoutView(workout: workout!,
                                                          frame: .zero)
                createWorkoutView.showViewDelegate = showViewDelegate
                showViewDelegate?.showView(createWorkoutView)
            } else {
                let alert = CDAlertView(title: "Cannot Edit Workout",
                                        message: "You cannot edit the selected workout from this view while the workout is in an active session. Please modify the workout from the active session view.",
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: "Ok",
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            }
        default:
            fatalError("User pressed a button that does not exist?")
        }
    }
    
    // MARK: Constraint functions

    // Below view top ; cling to left of view ; to the right of the fire image ; height of default height
    private func createAndActivateCellTitleConstraints() {
        
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: fireImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Width 16 ; height 8.46 ; center in this view ; 10 pixels from the right.
    private func createAndActivateExpandImageConstraints() {
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage, width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage, height: 8.46).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
    }
    
    // Width of 72 ; height of 20 ; 15 from top ; cling to expand image's left side
    private func createAndActivateStreakLabelConstraints() {
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createWidthConstraintForView(view: streakLabel,
                                                        width: 72).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: streakLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: streakLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 15).isActive = true
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: streakLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: -10).isActive = true
    }
    
    // Width/height of 25 ; 12.5 from top ; cling to streak label's left side
    private func createAndActivateFireImageConstraints() {
        fireImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createWidthConstraintForView(view: fireImage,
                                                        width: 25).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: fireImage,
                                                         height: 25).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: fireImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 12.5).isActive = true
        NSLayoutConstraint(item: streakLabel,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: fireImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
