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

class WorkoutsView: UIView {
    
    // MARK: View properties
    
    // The delegate to display an exercise
    public var exerciseDisplayer: ExerciseDisplayer?
    
    // The workouts for this view
    private let workoutTableView: WorkoutTableView
    // The button to create this workout
    private let createWorkoutButton: PrettyButton
    
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        workoutTableView = WorkoutTableView(style: UITableViewStyle.plain)
        createWorkoutButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(workoutTableView)
        addSubview(createWorkoutButton)
        
        createAndActivateWorkoutTableViewConstraints()
        createCreateWorkoutButtonConstraints()
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
        
        backgroundColor = .lightestBlackWhiteColor
        
        createWorkoutButton.setDefaultProperties()
        createWorkoutButton.setTitle(NSLocalizedString("WorkoutView.Button.CreateWorkout", comment: ""),
                                     for: .normal)
        createWorkoutButton.addTarget(self,
                                      action: #selector(showCreateWorkoutView(sender:)),
                                      for: .touchUpInside)
        workoutTableView.reloadData()
        
        super.layoutSubviews()
    }
    
    // MARK: Event functions
    
    // Shows the create workout view
    @objc func showCreateWorkoutView(sender: PrettyButton) {
        let createWorkoutView: CreateWorkoutView = CreateWorkoutView(frame: .zero)
        
        createWorkoutView.dataDelegate = self
        createWorkoutView.showViewDelegate = self
        
        showView(createWorkoutView)
    }
    
    // MARK: Constraint functions
    
    // Cling to top, left, right of this view - 10, height of this view - 70
    private func createAndActivateWorkoutTableViewConstraints() {
        workoutTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutTableView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: createWorkoutButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: workoutTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to top,left,right of workouttableview ; bottom is self view
    private func createCreateWorkoutButtonConstraints() {
        createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutButton,
                                                             withCopyView: workoutTableView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutButton,
                                                             withCopyView: workoutTableView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createWorkoutButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
}

extension WorkoutsView: CreateWorkoutViewDelegate {
    // Called when a workout was created
    func finishedWithWorkout(workout: Workout) {
        workoutTableView.reloadData()
        
        layoutSubviews()
    }
}

extension WorkoutsView: ShowViewDelegate {
    // Shows a view over this view
    func showView(_ view: UIView) {
        addSubview(view)
        UIView.slideView(view, overView: self)
    }
}

extension WorkoutsView: ExerciseDisplayer {
    // Calls this delegate to display the exercise
    func displayExercise(_ exercise: Exercise) {
        exerciseDisplayer?.displayExercise(exercise)
    }
}
