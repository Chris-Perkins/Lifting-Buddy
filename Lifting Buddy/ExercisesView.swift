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

class ExercisesView: UIView, CreateExerciseViewDelegate {
    
    // MARK: View properties
    
    // The workouts for this view
    private var exerciseTableView: ExercisesTableView
    // The button to create this workout
    private var createExerciseButton: PrettyButton
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        let realm = try! Realm()
        
        let exercises = realm.objects(Exercise.self)
        
        exerciseTableView = ExercisesTableView(exercises: AnyRealmCollection(exercises),
                                               style: UITableViewStyle.plain)
        createExerciseButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(exerciseTableView)
        self.addSubview(createExerciseButton)
        
        self.createAndActivateExerciseTableViewConstraints()
        self.createCreateExerciseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        /* update the streaks in case we missed one
         * Done here rather than in init in case user never
         * Closes the app
         */
        Workout.updateAllStreaks()
        
        createExerciseButton.setDefaultProperties()
        createExerciseButton.setTitle("Create New Exercise", for: .normal)
        createExerciseButton.addTarget(self,
                                      action: #selector(showCreateExerciseView(sender:)),
                                      for: .touchUpInside)
        exerciseTableView.reloadData()
        
        super.layoutSubviews()
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
        // do something
    }
}
