//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    private var exerciseNameLabel: UILabel
    private var editButton: PrettyButton
    private var exercise: Exercise?
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.exerciseNameLabel = UILabel()
        self.editButton = PrettyButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(exerciseNameLabel)
        self.addSubview(editButton)
        
        
        /*
         * Comments for below code: Name label takes up 75% of the view
         * starting from the left. For example: N = Name Label, E = Edit button
         * Layout is: NNNE
         */
        
        // MARK: Exercise Name label
        
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: exerciseNameLabel, attribute: .top, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: exerciseNameLabel, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: exerciseNameLabel, attribute: .width, multiplier: 3/2, constant: 25).isActive = true
        NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: exerciseNameLabel, attribute: .left, multiplier: 1, constant: -10).isActive = true
        
        
        // MARK: Edit button
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: editButton, attribute: .top, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: editButton, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: editButton, attribute: .width, multiplier: 3, constant: 25).isActive = true
        NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: editButton, attribute: .right, multiplier: 1, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.clipsToBounds = true
        
        exerciseNameLabel.setDefaultProperties()
        exerciseNameLabel.layer.cornerRadius = 5.0
        exerciseNameLabel.backgroundColor = UIColor.niceGray().withAlphaComponent(0.5)
        
        editButton.setDefaultProperties()
        editButton.removeOverlayView()
        editButton.animationTimeInSeconds = 0.1
        editButton.setOverlayStyle(style: .FADE)
        editButton.setTitle("Edit", for: .normal)
    }
    
    // MARK: Public methods
    
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        self.exerciseNameLabel.text = exercise.getName()
    }
}
