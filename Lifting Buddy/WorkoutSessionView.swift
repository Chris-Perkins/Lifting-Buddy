//
//  WorkoutSessionStartView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/9/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutSessionView: UIScrollView, WorkoutSessionTableViewDelegate, ExercisePickerDelegate {
    
    // MARK: View properties
    
    public var showViewDelegate: ShowViewDelegate?
    
    // Workout for this view
    private var workout: Workout?
    // Whether or not the workout is complete
    private var isComplete: Bool = false
    
    // The name label for this exercise
    private var workoutNameLabel: UILabel
    // The tableview holding EVERYTHING!!!
    public var workoutSessionTableView: WorkoutSessionTableView
    // Button press to add an exercise to this workout
    private var addExerciseButton: PrettyButton
    // the complete button for the exercise
    private var completeButton: PrettyButton
    // A button we can press to hide this view
    private var cancelButton: PrettyButton
    
    // Delegate to notify on workout start
    public var workoutSessionDelegate: WorkoutSessionStarter?
    
    // MARK: Inits
    
    init(workout: Workout?, frame: CGRect) {
        self.workout = workout
        
        self.workoutNameLabel = UILabel()
        self.workoutSessionTableView = WorkoutSessionTableView(workout: workout,
                                                               style: .plain)
        self.addExerciseButton = PrettyButton()
        self.completeButton = PrettyButton()
        self.cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.niceGray
        workoutSessionTableView.viewDelegate = self
        
        self.addSubview(workoutNameLabel)
        self.addSubview(workoutSessionTableView)
        self.addSubview(addExerciseButton)
        self.addSubview(completeButton)
        self.addSubview(cancelButton)
        
        self.createAndActivateWorkoutNameLabelConstraints()
        self.createAndActivateWorkoutSessionTableViewConstraints()
        self.createAndActivateAddExerciseButtonConstraints()
        self.createAndActivateCompleteButtonConstraints()
        self.createAndActivateCancelButtonConstraints()
        
        self.completeButton.addTarget(self,
                                      action: #selector(buttonPress(sender:)),
                                      for: .touchUpInside)
        self.addExerciseButton.addTarget(self,
                                         action: #selector(buttonPress(sender:)),
                                         for: .touchUpInside)
        self.cancelButton.addTarget(self,
                                    action: #selector(buttonPress(sender:)),
                                    for: .touchUpInside)
        
        workoutSessionTableView.checkComplete()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View func overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.workoutNameLabel.setDefaultProperties()
        self.workoutNameLabel.text = self.workout?.getName() ?? "Custom Workout"
        
        self.addExerciseButton.setDefaultProperties()
        self.addExerciseButton.setTitle("Add Exercise to Workout",
                                        for: .normal)
        
        // Modified by another method based on current complete
        self.completeButton.setOverlayStyle(style: .FADE)
        self.completeButton.setOverlayColor(color: UIColor.niceYellow)
        self.completeButton.setTitle("Finish Workout",
                                     for: .normal)
        
        self.cancelButton.setDefaultProperties()
        self.cancelButton.backgroundColor = UIColor.niceRed
        self.cancelButton.setTitle("Cancel Workout",
                                   for: .normal)
        
        self.contentSize = CGSize(width: self.frame.width,
                                  height: self.cancelButton.frame.maxY + 20)
    }
    
    // MARK: Private functions
    
    // Called on completion of the workout (sent by user)
    private func saveWorkoutData() {
        workoutSessionTableView.saveWorkoutData()
        
        self.workout?.setDateLastDone(date: Date(timeIntervalSinceNow: 0))
        self.workout?.incrementWorkoutCount()
    }
    
    // Completes this workout, dismisses the view.
    private func completeWorkout() {
        self.workoutSessionDelegate?.endWorkout!()
        self.saveWorkoutData()
        
        let view = WorkoutSessionSummaryView(workout: self.workout,
                                             exercises: self.workoutSessionTableView.getData())
        self.showViewDelegate?.showView(view: view)
        
        self.removeSelfNicelyWithAnimation()
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case self.addExerciseButton:
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
        case self.completeButton:
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
        case self.cancelButton:
            // Confirm that the user indeed wants to cancel this workout
            let alert = UIAlertController(title: "Cancel Workout?",
                                          message: "Canceling will not save any data about this workout. Continue?",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default,
                                         handler: {(UIAlertAction) -> Void in
                                            self.removeSelfNicelyWithAnimation()
            })
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            self.viewController()!.present(alert, animated: true, completion: nil)
        default:
            fatalError("Button pressed that does not exist?")
        }
    }
    
    // MARK: ExercisePicker Delegate methods
    func didSelectExercise(exercise: Exercise) {
        self.workoutSessionTableView.appendDataToTableView(data: exercise)
    }
    
    // MARK: WorkoutSessionTableViewDelegate
    
    func updateCompleteStatus(isComplete: Bool) {
        self.isComplete = isComplete
        
        if isComplete {
            self.backgroundColor = UIColor.niceLightGreen
            completeButton.backgroundColor = UIColor.niceGreen
        } else {
            self.backgroundColor = UIColor.niceGray
            completeButton.backgroundColor = UIColor.niceLightBlue
        }
    }
    
    // Height of this view changed
    func heightChange() {
        self.layoutSubviews()
    }
    
    // MARK: View Constraints
    
    // Center horiz in view ; place below top of this view ; height 20 ; width of this view - 80
    private func createAndActivateWorkoutNameLabelConstraints() {
        self.workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 30).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.workoutNameLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -80.0).isActive = true
        
    }
    
    // Center horiz in view ; below workoutNameLabel ; height 0 ; width of this view
    private func createAndActivateWorkoutSessionTableViewConstraints() {
        self.workoutSessionTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutSessionTableView,
                                                        withCopyView: self,
                                                        attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.workoutSessionTableView,
                                                         belowView: self.workoutNameLabel,
                                                         withPadding: 15).isActive = true
        
        // Assign height constraint
        self.workoutSessionTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: self.workoutSessionTableView,
                                                             height: 0)
        self.workoutSessionTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutSessionTableView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
    }
    
    // Below workout view ; left/right of tableview ; height of tableview cell
    private func createAndActivateAddExerciseButtonConstraints() {
        self.addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.addExerciseButton,
                                                         belowView: self.workoutSessionTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutSessionTableView,
                                                             withCopyView: self.addExerciseButton,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutSessionTableView,
                                                             withCopyView: self.addExerciseButton,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addExerciseButton,
                                                         height: WorkoutSessionTableView.baseCellHeight).isActive = true
    }
    
    // center horiz in view ; place below workoutSessionTableView ; height 50 ; width of this view - 80
    private func createAndActivateCompleteButtonConstraints() {
        self.completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.completeButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.completeButton,
                                                         belowView: self.addExerciseButton,
                                                         withPadding: 25).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.completeButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.completeButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -80).isActive = true
    }
    
    // Center horiz in self ; below completeButton ; height 40 ; copy width of completeButton
    private func createAndActivateCancelButtonConstraints() {
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.cancelButton,
                                                         belowView: self.completeButton,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                            withCopyView: self.completeButton,
                                                            attribute: .width).isActive = true
    }
}
