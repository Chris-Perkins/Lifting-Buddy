//
//  ExercisesView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/29/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ExercisesView: UIView {
    
    // MARK: View properties
    
    // Notified when we pick an exercise
    public var exercisePickerDelegate: ExercisePickerDelegate?
    
    // Whether or not we're simply selecting an exercise
    private let selectingExercise: Bool
    
    // The view we display when the tableview is empty
    private var overlayView: UIView?
    
    // The workouts for this view
    private let exerciseTableView: ExercisesTableView
    // The button to create this workout
    private let createExerciseButton: PrettyButton
    // A button to cancel this view (only visible if selecting exercise)
    private let cancelButton: PrettyButton
    
    // MARK: View inits
    
    required init(selectingExercise: Bool = false, frame: CGRect) {
        self.selectingExercise = selectingExercise
        let realm = try! Realm()
        
        let exercises = realm.objects(Exercise.self)
        
        exerciseTableView = ExercisesTableView(exercises: AnyRealmCollection(exercises),
                                               selectingExercise: selectingExercise,
                                               style: UITableViewStyle.plain)
        createExerciseButton = PrettyButton()
        cancelButton = PrettyButton()
        
        
        super.init(frame: frame)
        
        addSubview(exerciseTableView)
        addSubview(createExerciseButton)
        addSubview(cancelButton)
        
        createAndActivateCancelButtonConstraints()
        createCreateExerciseButtonConstraints()
        createAndActivateExerciseTableViewConstraints()
        
        exerciseTableView.exercisePickerDelegate = self
        exerciseTableView.overlayDelegate = self
        
        createExerciseButton.addTarget(self,
                                       action: #selector(showCreateExerciseView(sender:)),
                                       for: .touchUpInside)
        cancelButton.addTarget(self,
                               action: #selector(removeSelf),
                               for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .niceGray
        
        createExerciseButton.setDefaultProperties()
        createExerciseButton.setTitle(selectingExercise ?
            "Add New Exercise" :
            "Create New Exercise", for: .normal)
        
        if selectingExercise {
            cancelButton.setDefaultProperties()
            cancelButton.backgroundColor = .niceRed
            cancelButton.setTitle("Cancel", for: .normal)
        } else {
            cancelButton.alpha = 0
        }
        
        exerciseTableView.reloadData()
    }
    
    // MARK: View functions
    
    // Just removes this view
    @objc func removeSelf() {
        removeSelfNicelyWithAnimation()
    }
    
    // We must refresh in case a new exercise was created mid-workout
    func endWorkout() {
        exerciseTableView.reloadData()
    }
    
    // MARK: Event functions
    
    @objc func showCreateExerciseView(sender: PrettyButton) {
        let createExerciseView: CreateExerciseView = CreateExerciseView(frame: .zero)
        
        createExerciseView.dataDelegate = self
        
        showView(view: createExerciseView)
    }
    
    // MARK: Constraint functions
    
    // Cling to top, left, right of this view ; bottom of this view @ createButton
    private func createAndActivateExerciseTableViewConstraints() {
        exerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: createExerciseButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: exerciseTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to left,right of this view ; place above cancel button ; height of prettybutton default height
    private func createCreateExerciseButtonConstraints() {
        createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: cancelButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: createExerciseButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // cling to left, right, bottom of this view ; height of 0 or default height - 5 (depends on selecting exercise)
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        // make this button basically invisible if we're not selecting an exercise
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: selectingExercise ? PrettyButton.defaultHeight - 5 : 0).isActive = true
    }
    
    // Center in view ; height 50 ; width of 85% of this view.
    private func createAndActivateOverlayButtonConstraints(overlayButton: UIButton) {
        guard let overlayView = overlayView else {
            fatalError("Unable to attach constraints; Overlay view nil")
        }
        
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: overlayView,
                                                             withCopyView: overlayButton,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: overlayView,
                                                             withCopyView: overlayButton,
                                                             attribute: .centerY).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: overlayButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: overlayButton,
                                                             withCopyView: overlayView,
                                                             attribute: .width,
                                                             multiplier: 0.85).isActive = true
    }
}

extension ExercisesView: ExercisePickerDelegate {
    // when we select an exercise, return it.
    func didSelectExercise(exercise: Exercise) {
        exercisePickerDelegate?.didSelectExercise(exercise: exercise)
        removeSelfNicelyWithAnimation()
    }
}

extension ExercisesView: WorkoutSessionStarter {
    // Starts a workout based on the information we're given
    func startWorkout(workout: Workout?, exercise: Exercise?) {
        let startWorkoutView = WorkoutSessionView(workout: workout,
                                                  frame: .zero)
        startWorkoutView.workoutSessionDelegate = self
        startWorkoutView.showViewDelegate = self
        
        if let appendedExercise = exercise {
            startWorkoutView.workoutSessionTableView.appendDataToTableView(data: appendedExercise)
        }
        
        showView(view: startWorkoutView)
    }
}

extension ExercisesView: CreateExerciseViewDelegate {
    // Called when a workout is created from this view
    func finishedWithExercise(exercise: Exercise) {
        // if we're selecting an exercise, return the one we just made.
        if selectingExercise {
            exercisePickerDelegate?.didSelectExercise(exercise: exercise)
            removeSelfNicelyWithAnimation()
        } else {
            exerciseTableView.reloadData()
            exerciseTableView.layoutSubviews()
        }
    }
}

extension ExercisesView: ShowViewDelegate {
    // Shows a view over this one
    func showView(view: UIView) {
        addSubview(view)
        
        view.frame = CGRect(x: 0,
                            y: -frame.height,
                            width: frame.width,
                            height: frame.height)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.frame = CGRect(x: 0,
                                y: 0,
                                width: self.frame.width,
                                height: self.frame.height)
        })
    }
}

extension ExercisesView: TableViewOverlayDelegate {
    func showViewOverlay() {
        // If the view exists, don't create another.
        if overlayView != nil {
            return
        }
        /*overlayView = UIView()
         addSubview(overlayView!)
         NSLayoutConstraint.clingViewToView(view: overlayView!, toView: self)
         overlayView?.backgroundColor = .niceYellow
         
         let overlayButton = PrettyButton()
         addSubview(overlayButton)
         overlayButton.setTitle("Create Exercise", for: .normal)
         createAndActivateOverlayButtonConstraints(overlayButton: overlayButton)
         
         overlayButton.setDefaultProperties()
         overlayButton.addTarget(self, action: #selector(showCreateExerciseView(sender:)), for: .touchUpInside)*/
    }
    
    func hideViewOverlay() {
        // hide the guy
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}

/* A protocol that is called when we select an exercise */
protocol ExercisePickerDelegate {
    /*
     * should be called whenever an exercise is selected from the tableview
     */
    func didSelectExercise(exercise: Exercise)
}
