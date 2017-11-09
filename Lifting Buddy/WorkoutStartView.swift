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
    // Whether or not the workout is complete
    private var isComplete: Bool = false
    
    // Delegate to notify on workout start
    public var workoutStartDelegate: WorkoutCellDelegate?
    
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
        workout?.incrementWorkoutCount()
    }
    
    // Completes this workout, dismisses the view.
    private func completeWorkout() {
        self.workoutStartDelegate?.endWorkout!()
        saveWorkoutData()
        self.removeSelfNicelyWithAnimation()
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case addExerciseButton:
            /*
             * We use superview here as this view is a scrollview. This could
             * alternatively be done by having an encasing view for every workoutview.
             * That may be considered best practice... So, TODO
             */
            let frame = CGRect(x: 0,
                               y: -self.superview!.frame.height,
                               width: self.superview!.frame.width,
                               height: self.superview!.frame.height)
            
            let chooseExerciseView = ExercisesView(selectingExercise: true, frame: frame)
            chooseExerciseView.layer.zPosition = 100
            chooseExerciseView.exercisePickerDelegate = self
            self.superview!.addSubview(chooseExerciseView)
            
            UIView.animate(withDuration: 0.2, animations: {
                chooseExerciseView.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: self.superview!.frame.width,
                                                  height: self.superview!.frame.height)
            })
            break
        case completeButton:
            if self.isComplete {
                // If complete, we can just complete.
                self.completeWorkout()
            } else {
                // Otherwise, prompt for confirmation that we want to complete the workout.
                let alert = UIAlertController(title: "Complete Workout Prematurely?",
                                              message: "Not all workouts are complete.\nDo you really want to finish this workout?",
                                              preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: nil)
                let okAction = UIAlertAction(title: "Ok",
                                             style: .default,
                                             handler: {(UIAlertAction) -> Void in
                                                            self.completeWorkout()
                                                      })
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                
                self.viewController()!.present(alert, animated: true, completion: nil)
            }
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
        self.isComplete = isComplete
        
        if isComplete {
            self.backgroundColor = .niceLightGreen()
            completeButton.backgroundColor = .niceGreen()
        } else {
            self.backgroundColor = .niceGray()
            completeButton.backgroundColor = UIColor.niceLightBlue()
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
