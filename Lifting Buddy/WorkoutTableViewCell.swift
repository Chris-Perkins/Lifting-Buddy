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
    
    // These properties are used in determining the cell height for the tableview delegate
    public static let heightPerLabel: CGFloat = 40.0
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
    // Label stating how many times we've completed the displayed exercise
    private let completedLabel: UILabel
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
        completedLabel = UILabel()
        
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
        
        completedLabel.textAlignment = .center
        
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
            startWorkoutButton?.setTitle(NSLocalizedString("Button.StartWO", comment: ""), for: .normal)
        }
        
        // If the last time we did this workout was today...
        if let dateLastDone = workout?.getDateLastDone(),
            Calendar.current.isDateInToday(dateLastDone) {
            
            backgroundColor = .niceGreen
            
            setLabelTextColorsTo(color: .white)
        } else if workout?.isRepeatedToday == true {
            backgroundColor = .niceLightRed
            
            setLabelTextColorsTo(color: .white)
        } else {
            backgroundColor = isSelected ? .lightestBlackWhiteColor : .primaryBlackWhiteColor
            
            setLabelTextColorsTo(color: .niceBlue, streakLabelColor: .niceRed)
        }
        
        for (index, exerciseLabel) in exerciseLabels.enumerated() {
            exerciseLabel.backgroundColor = UIColor.oppositeBlackWhiteColor.withAlphaComponent(index&1 == 1 ?
                0.05 : 0.1)
            exerciseLabel.button.setDefaultProperties()
            exerciseLabel.label.textAlignment = .left
        }
    }
    
    // MARK: view functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        expandImage.transform = CGAffineTransform(scaleX: 1, y: isSelected ? -1 : 1)
        
        layoutIfNeeded()
    }
    
    // Removes views that have positions depend on the exercise labels
    private func removeExerciseDependentViews() {
        for exerciseLabel in exerciseLabels {
            exerciseLabel.removeFromSuperview()
        }
        
        editButton?.removeFromSuperview()
        startWorkoutButton?.removeFromSuperview()
        completedLabel.removeFromSuperview()
    }
    
    public func setLabelTextColorsTo(color: UIColor, streakLabelColor: UIColor? = nil) {
        cellTitle.textColor      = color
        streakLabel.textColor    = streakLabelColor ?? color
        
        
        // Only bother modifying views if they can be seen for performance
        if isSelected {
            completedLabel.textColor = color
            
            for exerciseLabel in exerciseLabels {
                exerciseLabel.label.textColor = color
            }
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set the workout for this cell
    public func setWorkout(workout: Workout) {
        removeExerciseDependentViews()
        exerciseLabels.removeAll()
        
        // TODO: Determine when a change is made so we don't have to be dumb in checking.
        //if workout != workout
        cellTitle.text = workout.getName()
        
        self.workout = workout
        
        editButton = PrettyButton()
        startWorkoutButton = PrettyButton()
        
        editButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        startWorkoutButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        addSubview(editButton!)
        addSubview(startWorkoutButton!)
        
        // Previous view
        var prevView: UIView = cellTitle
        
        exercises = workout.getExercises()
        for (index, exercise) in exercises.enumerated() {
            let exerciseView = LabelWithPrettyButtonView()
            
            addSubview(exerciseView)
            exerciseLabels.append(exerciseView)
            
            exerciseView.label.text = exercise.getName()!
            
            exerciseView.button.setTitle(NSLocalizedString("Button.View", comment: ""), for: .normal)
            exerciseView.button.tag = index
            exerciseView.button.addTarget(self,
                                          action: #selector(labelButtonPress(sender:)),
                                          for: .touchUpInside)
            
            createAndActivateViewBelowViewConstraints(view: exerciseView,
                                                      belowView: prevView,
                                                      withHeight: WorkoutTableViewCell.heightPerExercise)
            
            prevView = exerciseView
        }
        
        addSubview(completedLabel)
        createAndActivateViewBelowViewConstraints(view: completedLabel,
                                                  belowView: prevView,
                                                  withHeight: WorkoutTableViewCell.heightPerLabel)
        prevView = completedLabel
        
        completedLabel.text = workout.getCompletedCount() == 0 ?
                                "Workout not yet completed" :
                                "Completed \(workout.getCompletedCount()) times"
        
        createAndActivateStartEditWorkoutButtonConstraints(belowView: prevView)
        
        layoutSubviews()
    }
    
    // Returns this workout
    public func getWorkout() -> Workout? {
        return workout
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
    
    // Cling below belowView, left and right of self - 20 ; height of height
    private func createAndActivateViewBelowViewConstraints(view: UIView,
                                                           belowView: UIView,
                                                           withHeight height: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: view,
                                                         belowView: belowView).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: view,
                                                         height: height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -20).isActive = true
    }
    
    // clings below previous view ; width of this view ; height of prettybutton's default button
    private func createAndActivateStartEditWorkoutButtonConstraints(belowView: UIView) {
        editButton?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: editButton!,
                                                         belowView: belowView).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editButton!,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton!,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton!,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
        
        startWorkoutButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: startWorkoutButton!,
                                                         belowView: belowView).isActive = true
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
}
