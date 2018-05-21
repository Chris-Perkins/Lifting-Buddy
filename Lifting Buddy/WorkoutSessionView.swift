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

class WorkoutSessionView: UIView {
    
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
        
        backgroundColor = .lightestBlackWhiteColor
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
        backgroundColor = isComplete ? .niceLightGreen : .lightestBlackWhiteColor
        
        // Workout Name Label
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.textAlignment = .left
        workoutNameLabel.text =
            workout?.getName() ??
            NSLocalizedString("SessionView.Label.CustomWorkout", comment: "")
        workoutNameLabel.textColor       = isComplete ? .niceBlue : UILabel.titleLabelTextColor
        
        // Add Exercise Button
        addExerciseButton.setDefaultProperties()
        addExerciseButton.backgroundColor = .clear
        addExerciseButton.setImage(#imageLiteral(resourceName: "plus-sign"), for: .normal)
        
        // Complete button
        // Modified by another method based on current complete
        completeButton.setDefaultProperties()
        completeButton.backgroundColor = isComplete ? .niceGreen : .niceLightBlue
        completeButton.setTitle(NSLocalizedString("SessionView.Button.FinishWorkout", comment: ""),
                                for: .normal)
        
        // Cancel Button
        cancelButton.setDefaultProperties()
        cancelButton.backgroundColor = .niceRed
        cancelButton.setTitle(NSLocalizedString("SessionView.Button.CancelWorkout", comment: ""),
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
        
        if let workout = workout {
            MessageQueue.shared.append(Message(type: .workoutComplete,
                                               identifier: workout.getName(),
                                               value: String(describing: workout.getCompletedCount())))
        }
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
            /* Found here: https://stackoverflow.com/questions/37229132/swift-how-to-resign-first-responder-on-all-uitextfield
               Allows us to dismiss the keyboard on all possible textfields
            */
            endEditing(true)
            
            if isComplete {
                // If complete, we can just complete.
                completeWorkout()
            } else {
                // Otherwise, prompt for confirmation that we want to complete the workout.
                let alert = CDAlertView(title: NSLocalizedString("Message.EndSessionPrematurely.Title",
                                                                 comment: ""),
                                        message: NSLocalizedString("Message.EndSessionPrematurely.Desc",
                                                                   comment: ""),
                                        type: CDAlertViewType.warning)
                
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Cancel", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Complete", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceRed,
                                                    handler: { (CDAlertViewAction) in
                                                        self.completeWorkout()
                                                        return true
                }))
                alert.show()
            }
        case cancelButton:
            // Confirm that the user indeed wants to cancel this workout
            let alert = CDAlertView(title: NSLocalizedString("Message.CancelSession.Title", comment: ""),
                                    message: NSLocalizedString("Message.CancelSession.Desc", comment: ""),
                                    type: CDAlertViewType.warning)
            alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Cancel", comment: ""),
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue,
                                                handler: nil))
            alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.End", comment: ""),
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceRed,
                                                handler: { (CDAlertViewAction) in
                                                    self.endSession()
                                                    return true
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
    
    // Cling to left, top of self ; cling to right of ; height of title
    private func createAndActivateWorkoutNameLabelConstraints() {
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: addExerciseButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: workoutNameLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutNameLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: workoutNameLabel,
                                                         height: UILabel.titleLabelHeight).isActive = true
        
    }
    
    // Center horiz in view ; below workoutNameLabel ; height 0 ; width of this view
    private func createAndActivateWorkoutSessionTableViewConstraints() {
        workoutSessionTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: workoutSessionTableView,
                                                         belowView: workoutNameLabel).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutSessionTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: completeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: workoutSessionTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to top, right of self; copy height from namelabel
    private func createAndActivateAddExerciseButtonConstraints() {
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addExerciseButton,
                                                             withCopyView: workoutNameLabel,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint(item: addExerciseButton,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: addExerciseButton,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to right, bottom of view ; trailing cancel button ; height of cancel button
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: cancelButton,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint(item: cancelButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to left, bottom of self ; height default ; copy width of self * 0.5
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: PrettyButton.defaultHeight
                                                        ).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
}

extension WorkoutSessionView: WorkoutSessionTableViewDelegate {
    // Determine if we've completed this workout
    func updateCompleteStatus(isComplete: Bool) {
        self.isComplete = isComplete
        
        layoutSubviews()
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
