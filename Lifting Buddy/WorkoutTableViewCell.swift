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
    private var expandImage: UIImageView
    private var exerciseLabels: [UILabel]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        exerciseLabels = [UILabel]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellTitle)
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
        NSLayoutConstraint.createWidthConstraintForView(view: cellTitle, width: 150).isActive = true
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
            
            var prevLabel: UILabel? = nil
            
            for (index, exercise) in workout.getExercises().enumerated() {
                let exerLabel = UILabel()
                exerLabel.text = exercise.getName()
                exerLabel.textColor = UIColor.niceBlue()
                exerLabel.textAlignment = .left
                self.addSubview(exerLabel)
                
                // Constraints for this exercise label.
                // Place 10 from left/right of the cell
                // Place 10 below above view, height of 20
                
                exerLabel.translatesAutoresizingMaskIntoConstraints = false
                
                if index == 0 {
                    // set to top of this view
                   NSLayoutConstraint.createViewBelowViewConstraint(view: exerLabel,
                                                                    belowView: cellTitle,
                                                                    withPadding: 10).isActive = true
                } else {
                    NSLayoutConstraint.createViewBelowViewConstraint(view: exerLabel,
                                                                     belowView: prevLabel!,
                                                                     withPadding: 10).isActive = true
                }
                
                NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: exerLabel, attribute: .left, multiplier: 1, constant: -10).isActive = true
                NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: exerLabel, attribute: .right, multiplier: 1, constant: 10).isActive = true
                NSLayoutConstraint.createHeightConstraintForView(view: exerLabel, height: 20).isActive = true
                
                self.exerciseLabels.append(exerLabel)
                prevLabel = exerLabel
            }
            
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
    }
}
