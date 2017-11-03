//
//  WorkoutStartView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/9/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutStartView: UIScrollView, WorkoutStartTableViewDelegate, ExercisePickerDelegate {
    
    // MARK: View properties
    
    // Workout for this view
    private var workout: Workout?
    // The name label for this exercise
    private var workoutNameLabel: UILabel
    // The tableview holding EVERYTHING!!!
    public var workoutStartTableView: WorkoutStartTableView
    // Button press to add an exercise to this workout
    private var addExerciseButton: PrettyButton
    // the complete button for the exercise
    private var completeButton: PrettyButton
    
    // Delegate to notify on workout start
    public var workoutStartDelegate: StartWorkoutDelegate?
    
    // MARK: Inits
    
    init(workout: Workout?, frame: CGRect) {
        self.workout = workout
        
        workoutNameLabel = UILabel()
        workoutStartTableView = WorkoutStartTableView(workout: workout, style: .plain)
        addExerciseButton = PrettyButton()
        completeButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.niceGray()
        workoutStartTableView.viewDelegate = self
        
        self.addSubview(workoutNameLabel)
        self.addSubview(workoutStartTableView)
        self.addSubview(addExerciseButton)
        self.addSubview(completeButton)
        
        self.createAndActivateWorkoutNameLabelConstraints()
        self.createAndActivateWorkoutStartTableViewConstraints()
        self.createAndActivateAddExerciseButtonConstraints()
        self.createAndActivateCompleteButtonConstraints()
        
        completeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        addExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        workoutStartTableView.checkComplete()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View func overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.text = workout?.getName() ?? "Custom Workout"
        
        addExerciseButton.setDefaultProperties()
        addExerciseButton.setTitle("Add Exercise to Workout", for: .normal)
        
        completeButton.setOverlayStyle(style: .FADE)
        completeButton.setOverlayColor(color: .niceYellow())
        completeButton.setTitle("Finish Workout", for: .normal)
        
        self.contentSize = CGSize(width: self.frame.width, height: completeButton.frame.maxY + 20)
    }
    
    // MARK: Private functions
    
    // Called on completion of the workout (sent by user)
    private func saveWorkoutData() {
        workoutStartTableView.saveWorkoutData()
        
        workout?.setDateLastDone(date: Date(timeIntervalSinceNow: 0))
        workout?.incrementCurStreak()
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case addExerciseButton:
            let chooseExerciseView = ExercisesView(selectingExercise: true, frame: self.frame)
            chooseExerciseView.exercisePickerDelegate = self
            self.addSubview(chooseExerciseView)
            // TODO: Add exercise screen.
            break
        case completeButton:
            // complete button functions
            self.workoutStartDelegate?.endWorkout!()
            saveWorkoutData()
            self.removeSelfNicelyWithAnimation()
            break
        default:
            fatalError("Button pressed that does not exist?")
        }
    }
    
    // MARK: ExercisePicker Delegate methods
    func didSelectExercise(exercise: Exercise) {
        self.workoutStartTableView.appendDataToTableView(data: exercise)
    }
    
    // MARK: WorkoutStartTableViewDelegate
    
    func updateCompleteStatus(isComplete: Bool) {
        if isComplete {
            self.backgroundColor = .niceLightGreen()
            
            completeButton.backgroundColor = .niceGreen()
            completeButton.isEnabled = true
        } else {
            self.backgroundColor = .niceGray()
            
            completeButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            completeButton.isEnabled = false
        }
    }
    
    // Height of this view changed
    func heightChange() {
        self.layoutSubviews()
    }
    
    // MARK: View Constraints
    
    // Center horiz in view ; place below top of this view ; height 20 ; width of this view - 80
    private func createAndActivateWorkoutNameLabelConstraints() {
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: workoutNameLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: workoutNameLabel,
                                                            belowView: self,
                                                            withPadding: 30).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: workoutNameLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: workoutNameLabel,
                                                            withCopyView: self,
                                                            plusWidth: -80).isActive = true
        
    }
    
    // Center horiz in view ; below workoutNameLabel ; height 0 ; width of this view
    private func createAndActivateWorkoutStartTableViewConstraints() {
        workoutStartTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: workoutStartTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: workoutStartTableView,
                                                         belowView: workoutNameLabel,
                                                         withPadding: 15).isActive = true
        
        // Assign height constraint
        workoutStartTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: workoutStartTableView,
                                                             height: 0)
        workoutStartTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createWidthCopyConstraintForView(view: workoutStartTableView,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    // Below workout view ; left/right of tableview ; height of tableview cell
    private func createAndActivateAddExerciseButtonConstraints() {
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: addExerciseButton,
                                                         belowView: workoutStartTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: workoutStartTableView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: addExerciseButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: workoutStartTableView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: addExerciseButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addExerciseButton,
                                                         height: WorkoutStartTableView.baseCellHeight).isActive = true
    }
    
    // center horiz in view ; place below workoutStartTableView ; height 50 ; width of this view - 80
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: completeButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: completeButton,
                                                         belowView: addExerciseButton,
                                                         withPadding: 25).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: completeButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: completeButton,
                                                            withCopyView: self,
                                                            plusWidth: -80).isActive = true
    }
}
