//
//  WorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// View which shows information about a workout

import UIKit
import RealmSwift
import Realm

class WorkoutsView: UIView, CreateWorkoutViewDelegate, WorkoutCellDelegate {
    
    // View properties
    
    // The workouts for this view
    private var workoutTableView: WorkoutTableView
    // The button to create this workout
    private var createWorkoutButton: PrettyButton
    
    
    override init(frame: CGRect) {
        workoutTableView = WorkoutTableView(style: UITableViewStyle.plain)
        createWorkoutButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(workoutTableView)
        self.addSubview(createWorkoutButton)
        
        self.createAndActivateWorkoutTableViewConstraints()
        self.createCreateWorkoutButtonConstraints()
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
        
        createWorkoutButton.setDefaultProperties()
        createWorkoutButton.setTitle("Create New Workout", for: .normal)
        createWorkoutButton.addTarget(self,
                                      action: #selector(showCreateWorkoutView(sender:)),
                                      for: .touchUpInside)
        workoutTableView.reloadData()

        super.layoutSubviews()
    }
    
    // MARK: Event functions
    
    @objc func showCreateWorkoutView(sender: PrettyButton) {
        let createWorkoutView: CreateWorkoutView =
            CreateWorkoutView(frame: CGRect(x: 0,
                                            y: -self.frame.height,
                                            width: self.frame.width,
                                            height: self.frame.height))
        
        createWorkoutView.dataDelegate = self
        self.addSubview(createWorkoutView)
        
        UIView.animate(withDuration: 0.2, animations: {
            createWorkoutView.frame = CGRect(x: 0,
                                             y: self.frame.minY,
                                             width: self.frame.width,
                                             height: self.frame.height)
            
        })
    }
    
    // MARK: CreateWorkoutViewDelegate methods
    
    // We created a workout; update tableview
    func finishedWithWorkout(workout: Workout) {
        self.workoutTableView.refreshData()
        self.workoutTableView.reloadData()
        
        self.layoutSubviews()
    }
    
     // MARK: WorkoutCDelegate methods
    
    // Start the workout with workout or exercise
    func startWorkout(workout: Workout?, exercise: Exercise?) {
        let startWorkoutView = WorkoutStartView(workout: workout,
                                                frame: CGRect(x: 0,
                                                              y: -self.frame.height,
                                                              width: self.frame.width,
                                                              height: self.frame.height))
        self.addSubview(startWorkoutView)
        
        startWorkoutView.workoutStartTableView.appendDataToTableView(data: exercise)
        
        UIView.animate(withDuration: 0.2, animations: {
            startWorkoutView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: self.frame.width,
                                            height: self.frame.height)
        })
    }
    
    // Show the edit workout view
    func editWorkout(workout: Workout) {
        let workoutEditView = CreateWorkoutView(workout: workout,
                                                frame: CGRect(x: 0,
                                                              y: -self.frame.height,
                                                              width: self.frame.width,
                                                              height: self.frame.height))
        self.addSubview(workoutEditView)
        UIView.animate(withDuration: 0.2, animations: {
            workoutEditView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: self.frame.width,
                                           height: self.frame.height)
        })
    }
    
    // MARK: Constraint functions
    
    // Cling to top, left, right of this view - 10, height of this view - 70
    private func createAndActivateWorkoutTableViewConstraints() {
        workoutTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: workoutTableView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: workoutTableView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: workoutTableView,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: workoutTableView,
                           attribute: .height,
                           multiplier: 1, constant: 50).isActive = true
    }
    
    // Cling to bottom,left,right of workouttableview, place 10 above this view's bottom
    private func createCreateWorkoutButtonConstraints() {
        createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: workoutTableView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: workoutTableView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createWorkoutButton,
                                                         belowView: workoutTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
