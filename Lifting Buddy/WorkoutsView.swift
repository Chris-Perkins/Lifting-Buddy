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

class WorkoutsView: UIView, CreateWorkoutViewDelegate, StartWorkoutDelegate {
    
    // View properties
    
    var createWorkoutButton: PrettyButton
    var workoutViews: [ExpandableButton]
    var loaded = false
    
    override init(frame: CGRect) {
        createWorkoutButton = PrettyButton()
        workoutViews = [ExpandableButton]()
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        if !loaded {
            let realm = try! Realm()
            let workouts = realm.objects(Workout.self).toArray()
                
            // Table view of workouts
            let tableView = WorkoutTableView(workouts: workouts,
                                             frame: CGRect(x: 10,
                                                           y: 10,
                                                           width: self.frame.width - 20,
                                                           height: self.frame.height - 70),
                                             style: .plain)
            tableView.layer.zPosition = -10
            self.addSubview(tableView)
            
            // MARK: create workout button
            
            createWorkoutButton = PrettyButton()
            createWorkoutButton.setDefaultProperties()
            createWorkoutButton.setTitle("Create New Workout", for: .normal)
            createWorkoutButton.addTarget(self, action: #selector(showCreateWorkoutView(sender:)), for: .touchUpInside)
            self.addSubview(createWorkoutButton)
            
            createCreateWorkoutButtonConstraints(belowView: tableView)
            
            loaded = true
        } else {
            createWorkoutButton.isUserInteractionEnabled = true
            createWorkoutButton.layoutSubviews()
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Constraint functions
    
    private func createCreateWorkoutButtonConstraints(belowView: UIView) {
        createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        // Place below the tableview with padding from bottom of this view
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createWorkoutButton,
                                                         belowView: belowView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: createWorkoutButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 10).isActive = true
    }
    
    // MARK: Event functions
    
    @objc func showCreateWorkoutView(sender: PrettyButton) {
        let createWorkoutView: CreateWorkoutView =
            CreateWorkoutView(frame: CGRect(x: 0,
                                            y: -self.frame.height,
                                            width: self.frame.width,
                                            height: self.frame.height))
        createWorkoutView.layer.zPosition = 100
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
        // TODO: Realm write new workout
        
        // Recreate floaty button
        self.loaded = false
        self.removeAllSubviews()
        self.layoutSubviews()
    }
    
     // MARK: StartWorkoutDelegate methods
    
    func startWorkout(workout: Workout) {
        let startWorkoutView = WorkoutStartView(workout: workout,
                                                frame: CGRect(x: 0,
                                                              y: -self.frame.height,
                                                              width: self.frame.width,
                                                              height: self.frame.height))
        self.addSubview(startWorkoutView)
        
        UIView.animate(withDuration: 0.2, animations: {
            startWorkoutView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: self.frame.width,
                                            height: self.frame.height)
        })
    }
}
