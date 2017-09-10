//
//  WorkoutStartView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/9/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartView: UIView {
    
    // MARK: View properties
    
    private var workout: Workout
    
    private var workoutNameLabel: UILabel
    private var completeButton: PrettyButton
    
    // MARK: Inits
    
    init(workout: Workout, frame: CGRect) {
        self.workout = workout
        
        workoutNameLabel = UILabel()
        completeButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(workoutNameLabel)
        self.addSubview(completeButton)
        
        createWorkoutNameLabelConstraints()
        
        // MARK: Complete button properties
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View func overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.niceGray()
        
        workoutNameLabel.setDefaultProperties()
        workoutNameLabel.text = workout.getName()
        
        completeButton.setDefaultProperties()
        completeButton.setTitle("Finish Workout", for: .normal)
        completeButton.backgroundColor = UIColor.niceGreen()
        
    }
    
    // MARK: Private functions
    
    // MARK: View Constraints
    
    private func createWorkoutNameLabelConstraints() {
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: workoutNameLabel,
                           attribute: .top,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: workoutNameLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: workoutNameLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: workoutNameLabel,
                                                        width: 20).isActive = true
        
    }
}
