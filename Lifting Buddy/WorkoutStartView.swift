//
//  WorkoutStartView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/9/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartView: UIScrollView, WorkoutStartTableViewDelegate {
    
    // MARK: View properties
    
    private var workout: Workout
    
    private var workoutNameLabel: UILabel
    private var workoutStartTableView: WorkoutStartTableView
    private var completeButton: PrettyButton
    
    // MARK: Inits
    
    init(workout: Workout, frame: CGRect) {
        self.workout = workout
        
        workoutNameLabel = UILabel()
        workoutStartTableView = WorkoutStartTableView(workout: workout, style: .plain)
        completeButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.niceGray()
        workoutStartTableView.viewDelegate = self
        
        self.addSubview(workoutNameLabel)
        self.addSubview(workoutStartTableView)
        self.addSubview(completeButton)
        
        self.createAndActivateWorkoutNameLabelConstraints()
        self.createAndActivateWorkoutStartTableViewConstraints()
        
        workoutStartTableView.checkComplete()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View func overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Workout name label
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.text = workout.getName()
        
        // Complete button
        completeButton.setDefaultProperties()
        completeButton.setTitle("Finish Workout", for: .normal)
        completeButton.backgroundColor = UIColor.niceGreen()
        
        self.contentSize = CGSize(width: self.frame.width, height: workoutStartTableView.frame.maxY)
    }
    
    // MARK: Private functions
    
    // MARK: View Constraints
    
    // Center horiz in view ; place below top of this view ; height 20 ; width of this view - 80
    private func createAndActivateWorkoutNameLabelConstraints() {
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: workoutNameLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: workoutNameLabel,
                                                            belowView: self,
                                                            withPadding: 30).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: workoutNameLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: workoutNameLabel,
                                                            withCopyView: self,
                                                            plusWidth: -80).isActive = true
        
    }
    
    private func createAndActivateWorkoutStartTableViewConstraints() {
        workoutStartTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: workoutStartTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: workoutStartTableView,
                                                         belowView: workoutNameLabel,
                                                         withPadding: 15).isActive = true
        
        // Assign height constraint
        workoutStartTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: workoutStartTableView,
                                                             height: 0)
        workoutStartTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createWidthCopyConstraintForView(view: workoutStartTableView,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    // MARK: WorkoutStartTableViewDelegate
    
    func updateCompleteStatus(isComplete: Bool) {
        if isComplete {
            self.backgroundColor = UIColor.niceLightGreen()
        } else {
            self.backgroundColor = UIColor.niceGray()
        }
    }
    
    func heightChange() {
        self.layoutSubviews()
    }
}
