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
import CDAlertView

class WorkoutSessionView: UIScrollView {
    
    // MARK: View properties
    
    // Delegate to notify on workout start
    public var workoutSessionDelegate: WorkoutSessionStarter?
    
    // Workout for this view
    private var workout: Workout?
    // Whether or not the workout is complete
    private var isComplete: Bool = false
    
    // The tableview holding EVERYTHING!!!
    public let workoutSessionTableView: WorkoutSessionTableView
    // The name label for this exercise
    private let workoutNameLabel: UILabel
    // Button press to add an exercise to this workout
    private let addExerciseButton: PrettyButton
    // the complete button for the exercise
    private let completeButton: PrettyButton
    // A button we can press to hide this view
    private let cancelButton: PrettyButton
    
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
        
        // Self stuff
        contentSize = CGSize(width: frame.width,
                             height: cancelButton.frame.maxY + 20)
        
        // Workout Name Label
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.text = workout?.getName() ?? "Custom Workout"
        //workoutNameLabel.backgroundColor = .white
        
        // Add Exercise Button
        addExerciseButton.setDefaultProperties()
        addExerciseButton.setTitle("Add Exercise to Workout",
                                   for: .normal)
        
        // Complete button
        // Modified by another method based on current complete
        completeButton.setOverlayStyle(style: .FADE)
        completeButton.setOverlayColor(color: .niceYellow)
        completeButton.setTitle("Finish Workout",
                                for: .normal)
        
        // Cancel Button
        cancelButton.setDefaultProperties()
        cancelButton.backgroundColor = .niceRed
        cancelButton.setTitle("Cancel Workout",
                              for: .normal)
    }
    
    // MARK: Private functions
    
    // Called on completion of the workout (sent by user)
    private func saveWorkoutData() {
        workout?.incrementWorkoutCount()
    }
    
    // When we complete the workout, show the summary screen.
    private func completeWorkout() {
        workout?.incrementWorkoutCount()
        workout?.setDateLastDone(date: Date(timeIntervalSinceNow: 0))
        
        let summaryView = WorkoutSessionSummaryView(workout: workout,
                                                    exercises: workoutSessionTableView.getData())
        summaryView.workoutSessionDelegate = workoutSessionDelegate
        
        showView(summaryView)
        
        workoutSessionDelegate?.sessionViewChanged(toView: summaryView)
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case addExerciseButton:
            let chooseExerciseView = ExercisesView(selectingExercise: true, frame: .zero)
            chooseExerciseView.layer.zPosition = 100
            chooseExerciseView.exercisePickerDelegate = self
            showView(chooseExerciseView)
        case completeButton:
            if isComplete {
                // If complete, we can just complete.
                completeWorkout()
            } else {
                // Otherwise, prompt for confirmation that we want to complete the workout.
                let alert = CDAlertView(title: "Complete Workout Prematurely?",
                                        message: "Not all exercises are complete.\n" +
                                            "Complete the workout anyways?",
                                        type: CDAlertViewType.warning)
                
                alert.add(action: CDAlertViewAction(title: "Cancel",
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                
                alert.add(action: CDAlertViewAction(title: "Complete",
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceRed,
                                                    handler: { (CDAlertViewAction) in
                                                        self.completeWorkout()
                }))
                alert.show()
            }
        case cancelButton:
            // Confirm that the user indeed wants to cancel this workout
            let alert = CDAlertView(title: "End Session?",
                                    message: "This will not delete any previously saved set data.",
                                    type: CDAlertViewType.warning)
            alert.add(action: CDAlertViewAction(title: "Cancel",
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue,
                                                handler: nil))
            alert.add(action: CDAlertViewAction(title: "End",
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceRed,
                                                handler: { (CDAlertViewAction) in
                                                    self.endSession()
            }))
            
            alert.show()
        default:
            fatalError("Button pressed that does not exist?")
        }
    }
    
    // Ends the session by calling delegate
    public func endSession() {
        self.workoutSessionDelegate?.endSession(workout: workout, exercises: workoutSessionTableView.getData())
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

extension WorkoutSessionView: ShowViewDelegate {
    // Should only be called by a session view. slide it over.
    func showView(_ view: UIView) {
        // Need to call upon the superview as this is a scroll view.
        superview!.addSubview(view)
        UIView.slideView(view, overView: superview!)
    }
}

extension WorkoutSessionView: ExercisePickerDelegate {
    // Add this data to our tableview
    func didSelectExercise(exercise: Exercise) {
        workoutSessionTableView.appendDataToTableView(data: exercise)
        // Since this exercise is now a part of the workout, we should add it as such.
        sessionExercises.insert(exercise)
    }

}
