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

class WorkoutSessionView: UIScrollView {
    
    // MARK: View properties
    
    public var showViewDelegate: ShowViewDelegate?
    
    // Workout for this view
    private var workout: Workout?
    // Whether or not the workout is complete
    private var isComplete: Bool = false
    
    // The name label for this exercise
    private let workoutNameLabel: UILabel
    // The tableview holding EVERYTHING!!!
    public let workoutSessionTableView: WorkoutSessionTableView
    // Button press to add an exercise to this workout
    private let addExerciseButton: PrettyButton
    // the complete button for the exercise
    private let completeButton: PrettyButton
    // A button we can press to hide this view
    private let cancelButton: PrettyButton
    
    // Delegate to notify on workout start
    public var workoutSessionDelegate: WorkoutSessionStarter?
    
    // MARK: Inits
    
    init(workout: Workout?, frame: CGRect) {
        self.workout = workout
        
        workoutNameLabel = UILabel()
        workoutSessionTableView = WorkoutSessionTableView(workout: workout,
                                                          style: .plain)
        addExerciseButton = PrettyButton()
        completeButton = PrettyButton()
        cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        backgroundColor = .niceGray
        workoutSessionTableView.viewDelegate = self
        
        addSubview(workoutNameLabel)
        addSubview(workoutSessionTableView)
        addSubview(addExerciseButton)
        addSubview(completeButton)
        addSubview(cancelButton)
        
        createAndActivateWorkoutNameLabelConstraints()
        createAndActivateWorkoutSessionTableViewConstraints()
        createAndActivateAddExerciseButtonConstraints()
        createAndActivateCompleteButtonConstraints()
        createAndActivateCancelButtonConstraints()
        
        completeButton.addTarget(self,
                                 action: #selector(buttonPress(sender:)),
                                 for: .touchUpInside)
        addExerciseButton.addTarget(self,
                                    action: #selector(buttonPress(sender:)),
                                    for: .touchUpInside)
        cancelButton.addTarget(self,
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
        
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.text = workout?.getName() ?? "Custom Workout"
        //workoutNameLabel.backgroundColor = .white
        
        addExerciseButton.setDefaultProperties()
        addExerciseButton.setTitle("Add Exercise to Workout",
                                   for: .normal)
        
        // Modified by another method based on current complete
        completeButton.setOverlayStyle(style: .FADE)
        completeButton.setOverlayColor(color: .niceYellow)
        completeButton.setTitle("Finish Workout",
                                for: .normal)
        
        cancelButton.setDefaultProperties()
        cancelButton.backgroundColor = .niceRed
        cancelButton.setTitle("Cancel Workout",
                              for: .normal)
        
        contentSize = CGSize(width: frame.width,
                             height: cancelButton.frame.maxY + 20)
    }
    
    // MARK: Private functions
    
    // Called on completion of the workout (sent by user)
    private func saveWorkoutData() {
        workoutSessionTableView.saveWorkoutData()
        
        workout?.setDateLastDone(date: Date(timeIntervalSinceNow: 0))
        workout?.incrementWorkoutCount()
    }
    
    // Completes this workout, dismisses the view.
    private func completeWorkout() {
        saveWorkoutData()
        
        let view = WorkoutSessionSummaryView(workout: workout,
                                             exercises: workoutSessionTableView.getData())
        view.workoutSessionDelegate = workoutSessionDelegate
        
        guard let showViewDelegate = showViewDelegate else {
            fatalError("ShowViewDelegate not set for WorkoutSessionView")
        }
        showViewDelegate.showView(view)
        
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
                               y: -superview!.frame.height,
                               width: superview!.frame.width,
                               height: superview!.frame.height)
            
            let chooseExerciseView = ExercisesView(selectingExercise: true, frame: frame)
            chooseExerciseView.layer.zPosition = 100
            chooseExerciseView.exercisePickerDelegate = self
            superview!.addSubview(chooseExerciseView)
            
            UIView.animate(withDuration: 0.2, animations: {
                chooseExerciseView.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: self.superview!.frame.width,
                                                  height: self.superview!.frame.height)
            })
            break
        case completeButton:
            if isComplete {
                // If complete, we can just complete.
                completeWorkout()
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
                
                viewController()!.present(alert, animated: true, completion: nil)
            }
        case cancelButton:
            // Confirm that the user indeed wants to cancel this workout
            let alert = UIAlertController(title: "Cancel Workout?",
                                          message: "Canceling will cause all data from this workout to be lost. Continue?",
                                          preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default,
                                         handler: {(UIAlertAction) -> Void in
                self.workoutSessionDelegate?.endSession!()
            })
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            viewController()!.present(alert, animated: true, completion: nil)
        default:
            fatalError("Button pressed that does not exist?")
        }
    }
    
    // MARK: View Constraints
    
    // Center horiz in view ; place below top of this view ; height 20 ; width of this view - 80
    private func createAndActivateWorkoutNameLabelConstraints() {
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 12.5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: workoutNameLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        
    }
    
    // Center horiz in view ; below workoutNameLabel ; height 0 ; width of this view
    private func createAndActivateWorkoutSessionTableViewConstraints() {
        workoutSessionTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: workoutSessionTableView,
                                                         belowView: workoutNameLabel,
                                                         withPadding: 12.5).isActive = true
        
        // Assign height constraint
        workoutSessionTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: workoutSessionTableView,
                                                             height: 0)
        workoutSessionTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
    }
    
    // Below workout view ; left/right of tableview ; height of tableview cell
    private func createAndActivateAddExerciseButtonConstraints() {
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: addExerciseButton,
                                                         belowView: workoutSessionTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: addExerciseButton,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: addExerciseButton,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addExerciseButton,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // center horiz in view ; place below workoutSessionTableView ; height default; width of this view - 80
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: completeButton,
                                                         belowView: addExerciseButton,
                                                         withPadding: 25).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: completeButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -80).isActive = true
    }
    
    // Center horiz in self ; below completeButton ; height 40 ; copy width of completeButton
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: cancelButton,
                                                         belowView: completeButton,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: completeButton,
                                                             attribute: .width).isActive = true
    }
}

extension WorkoutSessionView: WorkoutSessionTableViewDelegate {
    // Determine if we've completed this workout
    func updateCompleteStatus(isComplete: Bool) {
        self.isComplete = isComplete
        
        if isComplete {
            backgroundColor = .niceLightGreen
            completeButton.backgroundColor = .niceGreen
        } else {
            backgroundColor = .niceGray
            completeButton.backgroundColor = .niceLightBlue
        }
    }
    
    // Height of this view changed
    func heightChange() {
        layoutSubviews()
    }
}

extension WorkoutSessionView: ExercisePickerDelegate {
    // Add this data to our tableview
    func didSelectExercise(exercise: Exercise) {
        workoutSessionTableView.appendDataToTableView(data: exercise)
        AppDelegate.sessionExercises.insert(exercise)
    }

}
