//
//  WorkoutTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private var cellTitle: UILabel
    private var workout: Workout?
    private var fireImage: UIImageView
    private var streakLabel: UILabel
    private var expandImage: UIImageView
    private var exerciseLabels: [UILabel]
    private var editButton: PrettyButton?
    private var startWorkoutButton: PrettyButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        fireImage = UIImageView(image: #imageLiteral(resourceName: "Fire"))
        streakLabel = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        exerciseLabels = [UILabel]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellTitle)
        self.addSubview(fireImage)
        self.addSubview(streakLabel)
        self.addSubview(expandImage)
        
        // MARK: Label constraints
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: cellTitle,
                                                            belowView: self,
                                                            withPadding: 5).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: fireImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: 40).isActive = true
        
        // MARK: Image constraints
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage, width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage, height: 8.46).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: expandImage,
                                                            belowView: self,
                                                            withPadding: 20.77).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: expandImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        
        // MARK: streak label constraints
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createWidthConstraintForView(view: streakLabel,
                                                        width: 72).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: streakLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: streakLabel,
                                                            belowView: self,
                                                            withPadding: 15).isActive = true
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: streakLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: -10).isActive = true
        
        // MARK: Streak fire icon
        fireImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createWidthConstraintForView(view: fireImage,
                                                        width: 25).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: fireImage,
                                                         height: 25).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: fireImage,
                                                            belowView: self,
                                                            withPadding: 12.5).isActive = true
        NSLayoutConstraint(item: streakLabel,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: fireImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        
        cellTitle.setDefaultProperties()
        cellTitle.textAlignment = .left
        
        streakLabel.text = "0000"
        streakLabel.textColor = UIColor.niceRed()
        
        if (self.isSelected) {
            editButton?.setDefaultProperties()
            editButton?.cornerRadius = 0
            editButton?.backgroundColor = UIColor.niceBlue().withAlphaComponent(0.75)
            editButton?.setTitle("Edit", for: .normal)
            
            startWorkoutButton?.setDefaultProperties()
            startWorkoutButton?.cornerRadius = 0
            startWorkoutButton?.backgroundColor = UIColor.niceGreen().withAlphaComponent(0.75)
            startWorkoutButton?.setTitle("Start Workout!", for: .normal)
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    // Set the workout for this cell
    public func setWorkout(workout: Workout) {
        // Only make changes if we need to.
        if workout != self.workout {
            self.workout = workout
            
            for label in exerciseLabels {
                label.removeFromSuperview()
            }
            exerciseLabels.removeAll()
            editButton?.removeFromSuperview()
            startWorkoutButton?.removeFromSuperview()
            
            // Previous
            var prevLabel: UILabel = cellTitle
            
            for exercise in workout.getExercises() {
                let exerLabel = UILabel()
                exerLabel.text = exercise.getName()
                exerLabel.textColor = UIColor.niceBlue()
                exerLabel.textAlignment = .left
                self.addSubview(exerLabel)
                
                // Constraints for this exercise label.
                // Place 10 from left/right of the cell
                // Place 10 below above view, height of 20
                
                exerLabel.translatesAutoresizingMaskIntoConstraints = false
                

                NSLayoutConstraint.createViewBelowViewConstraint(view: exerLabel,
                                                                     belowView: prevLabel,
                                                                     withPadding: 10).isActive = true
                NSLayoutConstraint(item: self,
                                   attribute: .left,
                                   relatedBy: .equal,
                                   toItem: exerLabel,
                                   attribute: .left,
                                   multiplier: 1,
                                   constant: -10).isActive = true
                NSLayoutConstraint(item: self,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: exerLabel,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 10).isActive = true
                NSLayoutConstraint.createHeightConstraintForView(view: exerLabel,
                                                                 height: 20).isActive = true
                
                self.exerciseLabels.append(exerLabel)
                prevLabel = exerLabel
            }
            
            editButton = PrettyButton()
            self.addSubview(editButton!)
            
            editButton?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.createViewBelowViewConstraint(view: editButton!,
                                                             belowView: prevLabel,
                                                             withPadding: 29).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: editButton!,
                                                             height: 50).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: editButton,
                               attribute: .left,
                               multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: editButton,
                               attribute: .width,
                               multiplier: 2,
                               constant: 0).isActive = true
            
            
            startWorkoutButton = PrettyButton()
            self.addSubview(startWorkoutButton!)
            
            startWorkoutButton?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.createViewBelowViewConstraint(view: startWorkoutButton!,
                                                             belowView: prevLabel,
                                                             withPadding: 29).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: startWorkoutButton!,
                                                             height: 50).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: startWorkoutButton,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: startWorkoutButton,
                               attribute: .width,
                               multiplier: 2,
                               constant: 0).isActive = true
            
            
            cellTitle.text = workout.getName()
        }
    }
    
    public func getWorkout() -> Workout? {
        return self.workout
    }
    
    public func getHeight() -> CGFloat {
        return self.frame.height
    }
    
    public func setHeight(height: CGFloat) {
        self.frame.size.height = height
    }
    
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutSubviews()
    }
}
