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

class ExercisesView: UIView, CreateExerciseViewDelegate, StartWorkoutDelegate, ExercisePickerDelegate {
    
    // MARK: View properties
    
    public var exercisePickerDelegate: ExercisePickerDelegate?
    // Whether or not we're simply selecting an exercise
    private var selectingExercise: Bool
    // The workouts for this view
    private var exerciseTableView: ExercisesTableView
    // The button to create this workout
    private var createExerciseButton: PrettyButton
    
    // MARK: View inits
    
    required init(selectingExercise: Bool = false, frame: CGRect) {
        self.selectingExercise = selectingExercise
        let realm = try! Realm()
        
        let exercises = realm.objects(Exercise.self)
        
        exerciseTableView = ExercisesTableView(exercises: AnyRealmCollection(exercises),
                                               selectingExercise: selectingExercise,
                                               style: UITableViewStyle.plain)
        createExerciseButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(exerciseTableView)
        self.addSubview(createExerciseButton)
        
        self.exerciseTableView.exercisePickerDelegate = self
        
        self.createAndActivateExerciseTableViewConstraints()
        self.createCreateExerciseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.niceGray()
        
        createExerciseButton.setDefaultProperties()
        createExerciseButton.setTitle(self.selectingExercise ?
                                        "Add New Exercise" :
                                        "Create New Exercise", for: .normal)
        createExerciseButton.addTarget(self,
                                      action: #selector(showCreateExerciseView(sender:)),
                                      for: .touchUpInside)
        exerciseTableView.reloadData()
    }
    
    // MARK: Event functions
    
    @objc func showCreateExerciseView(sender: PrettyButton) {
        let createWorkoutView: CreateExerciseView =
            CreateExerciseView(frame: CGRect(x: 0,
                                            y: -self.frame.height,
                                            width: self.frame.width,
                                            height: self.frame.height))
        
        createWorkoutView.dataDelegate = self
        self.addSubview(createWorkoutView)
        
        UIView.animate(withDuration: 0.5, animations: {
            createWorkoutView.frame = CGRect(x: 0,
                                             y: self.frame.minY,
                                             width: self.frame.width,
                                             height: self.frame.height)
            
        })
    }
    
    // MARK: CreateWorkoutViewDelegate methods
    
    func finishedWithWorkout(workout: Workout) {
        exerciseTableView.refreshData()
        self.exerciseTableView.reloadData()
        
        self.layoutSubviews()
    }
    
    // MARK: Constraint functions
    
    // Cling to top, left, right of this view - 10, height of this view - 70
    private func createAndActivateExerciseTableViewConstraints() {
        exerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: exerciseTableView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: exerciseTableView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: exerciseTableView,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: exerciseTableView,
                           attribute: .height,
                           multiplier: 1,
                           constant: 50).isActive = true
    }
    
    // Cling to bottom,left,right of workouttableview, place 10 above this view's bottom
    private func createCreateExerciseButtonConstraints() {
        createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: exerciseTableView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: createExerciseButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: exerciseTableView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: createExerciseButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createExerciseButton,
                                                         belowView: exerciseTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: createExerciseButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // MARK: CreateExerciseViewDelegate methods
    
    func finishedWithExercise(exercise: Exercise) {
        // if we're selecting an exercise, return the one we just made.
        if self.selectingExercise {
            self.exercisePickerDelegate?.didSelectExercise(exercise: exercise)
            self.removeSelfNicelyWithAnimation()
        } else {
            self.exerciseTableView.refreshData()
        }
    }
    
    // MARK: ExercisePickerDelegate methods
    func didSelectExercise(exercise: Exercise) {
        self.exercisePickerDelegate?.didSelectExercise(exercise: exercise)
        self.removeSelfNicelyWithAnimation()
    }
    
    // MARK: Start Workout Delegate methods
    
    func startWorkout(workout: Workout?, exercise: Exercise?) {
        let startWorkoutView = WorkoutStartView(workout: workout,
                                                frame: CGRect(x: 0,
                                                              y: -self.frame.height,
                                                              width: self.frame.width,
                                                              height: self.frame.height))
        startWorkoutView.workoutStartDelegate = self
        self.addSubview(startWorkoutView)
        
        startWorkoutView.workoutStartTableView.appendDataToTableView(data: exercise)
        
        UIView.animate(withDuration: 0.2, animations: {
            startWorkoutView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: self.frame.width,
                                            height: self.frame.height)
        })
    }
    
    // We must refresh in case a new exercise was created mid-workout
    func endWorkout() {
        self.exerciseTableView.refreshData()
    }
}

/* A protocol that is called when we select an exercise */
protocol ExercisePickerDelegate {
    /*
     * should be called whenever an exercise is selected from the tableview
     */
    func didSelectExercise(exercise: Exercise)
}
