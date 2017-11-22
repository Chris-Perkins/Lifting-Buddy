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

class ExercisesView: UIView, CreateExerciseViewDelegate, WorkoutSessionStarter, ExercisePickerDelegate,
                        TableViewOverlayDelegate, ShowViewDelegate {
    
    // MARK: View properties
    
    // Notified when we pick an exercise
    public var exercisePickerDelegate: ExercisePickerDelegate?
    
    // Whether or not we're simply selecting an exercise
    private var selectingExercise: Bool
    
    // The view we display when the tableview is empty
    private var overlayView: UIView?
    
    // The workouts for this view
    private var exerciseTableView: ExercisesTableView
    // The button to create this workout
    private var createExerciseButton: PrettyButton
    // A button to cancel this view (only visible if selecting exercise)
    private var cancelButton: PrettyButton
    
    // MARK: View inits
    
    required init(selectingExercise: Bool = false, frame: CGRect) {
        self.selectingExercise = selectingExercise
        let realm = try! Realm()
        
        let exercises = realm.objects(Exercise.self)
        
        self.exerciseTableView = ExercisesTableView(exercises: AnyRealmCollection(exercises),
                                                    selectingExercise: selectingExercise,
                                                    style: UITableViewStyle.plain)
        self.createExerciseButton = PrettyButton()
        self.cancelButton = PrettyButton()
        
        
        super.init(frame: frame)
        
        self.addSubview(exerciseTableView)
        self.addSubview(createExerciseButton)
        self.addSubview(cancelButton)
        
        self.createAndActivateCancelButtonConstraints()
        self.createCreateExerciseButtonConstraints()
        self.createAndActivateExerciseTableViewConstraints()
        
        self.exerciseTableView.exercisePickerDelegate = self
        self.exerciseTableView.overlayDelegate = self
        
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
        
        self.backgroundColor = UIColor.niceGray
        
        createExerciseButton.setDefaultProperties()
        createExerciseButton.setTitle(self.selectingExercise ?
                                        "Add New Exercise" :
                                        "Create New Exercise", for: .normal)
        
        if self.selectingExercise {
            cancelButton.setDefaultProperties()
            cancelButton.backgroundColor = UIColor.niceRed
            cancelButton.setTitle("Cancel", for: .normal)
        } else {
            cancelButton.alpha = 0
        }
        
        exerciseTableView.reloadData()
    }
    
    // MARK: View functions
    
    // Just removes this view
    @objc func removeSelf() {
        self.removeSelfNicelyWithAnimation()
    }
    
    // We must refresh in case a new exercise was created mid-workout
    func endWorkout() {
        self.exerciseTableView.reloadData()
    }
    
    // MARK: Event functions
    
    @objc func showCreateExerciseView(sender: PrettyButton) {
        let createExerciseView: CreateExerciseView = CreateExerciseView(frame: .zero)
        
        createExerciseView.dataDelegate = self
        
        self.showView(view: createExerciseView)
    }
    
    // MARK: CreateWorkoutViewDelegate methods
    
    func finishedWithWorkout(workout: Workout) {
        self.exerciseTableView.reloadData()
        
        self.layoutSubviews()
    }
    
    // MARK: Empty Table Overlay delegate methods
    
    func showViewOverlay() {
        // If the view exists, don't create another.
        if self.overlayView != nil {
            return
        }
        /*self.overlayView = UIView()
        self.addSubview(self.overlayView!)
        NSLayoutConstraint.clingViewToView(view: self.overlayView!, toView: self)
        self.overlayView?.backgroundColor = UIColor.niceYellow
        
        let overlayButton = PrettyButton()
        self.addSubview(overlayButton)
        overlayButton.setTitle("Create Exercise", for: .normal)
        self.createAndActivateOverlayButtonConstraints(overlayButton: overlayButton)
        
        overlayButton.setDefaultProperties()
        overlayButton.addTarget(self, action: #selector(showCreateExerciseView(sender:)), for: .touchUpInside)*/
    }
    
    func hideViewOverlay() {
        // hide the guy
        self.overlayView?.removeFromSuperview()
        self.overlayView = nil
    }
    
    // MARK: CreateExerciseViewDelegate methods
    
    func finishedWithExercise(exercise: Exercise) {
        // if we're selecting an exercise, return the one we just made.
        if self.selectingExercise {
            self.exercisePickerDelegate?.didSelectExercise(exercise: exercise)
            self.removeSelfNicelyWithAnimation()
        } else {
            self.exerciseTableView.reloadData()
            self.exerciseTableView.layoutSubviews()
        }
    }
    
    // MARK: ExercisePickerDelegate methods
    func didSelectExercise(exercise: Exercise) {
        self.exercisePickerDelegate?.didSelectExercise(exercise: exercise)
        self.removeSelfNicelyWithAnimation()
    }
    
    // MARK: Start Workout Delegate methods
    
    // Starts a workout based on the information we're given
    func startWorkout(workout: Workout?, exercise: Exercise?) {
        let startWorkoutView = WorkoutSessionView(workout: workout,
                                                  frame: .zero)
        startWorkoutView.workoutSessionDelegate = self
        startWorkoutView.showViewDelegate = self
        
        if let appendedExercise = exercise {
            startWorkoutView.workoutSessionTableView.appendDataToTableView(data: appendedExercise)
        }
        
        self.showView(view: startWorkoutView)
    }
    
    // MARK: Show View Protocol Methods
    
    // Shows a view
    func showView(view: UIView) {
        self.addSubview(view)
        
        view.frame = CGRect(x: 0,
                            y: -self.frame.height,
                            width: self.frame.width,
                            height: self.frame.height)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.frame = CGRect(x: 0,
                                y: 0,
                                width: self.frame.width,
                                height: self.frame.height)
        })
    }
    
    // MARK: Constraint functions
    
    // Cling to top, left, right of this view ; bottom of this view @ createButton
    private func createAndActivateExerciseTableViewConstraints() {
        self.exerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: self.createExerciseButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.exerciseTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to left,right of this view ; place above cancel button ; height of prettybutton default height
    private func createCreateExerciseButtonConstraints() {
        self.createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: self.cancelButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.createExerciseButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // cling to left, right, bottom of this view ; height of 0 or default height - 5 (depends on selecting exercise)
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        // make this button basically invisible if we're not selecting an exercise
        NSLayoutConstraint.createHeightConstraintForView(view: self.cancelButton,
                                                         height: self.selectingExercise ? PrettyButton.defaultHeight - 5 : 0).isActive = true
    }
    
    // Center in view ; height 50 ; width of 85% of this view.
    private func createAndActivateOverlayButtonConstraints(overlayButton: UIButton) {
        guard let overlayView = self.overlayView else {
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

/* A protocol that is called when we select an exercise */
protocol ExercisePickerDelegate {
    /*
     * should be called whenever an exercise is selected from the tableview
     */
    func didSelectExercise(exercise: Exercise)
}
