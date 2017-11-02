//
//  ExercisesTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/1/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // The title for every cell
    private var cellTitle: UILabel
    // The exercise associated with each cell
    private var exercise: Exercise?
    // The fire image displayed by streak
    private var fireImage: UIImageView
    // The label saying how many days we're on streak
    private var streakLabel: UILabel
    // An indicator on whether or not the cell is expanded
    private var expandImage: UIImageView
    // The labels for every exercise
    private var progressionLabels: [UILabel]
    
    // The button that allows for exercise editing
    private var editButton: PrettyButton?
    // A button to start the exercise
    private var startExerciseButton: PrettyButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        fireImage = UIImageView(image: #imageLiteral(resourceName: "Fire"))
        streakLabel = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        progressionLabels = [UILabel]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(cellTitle)
        self.addSubview(fireImage)
        self.addSubview(streakLabel)
        self.addSubview(expandImage)
        
        // MARK: Label constraints
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: cellTitle,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
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
                                                         height: ExercisesTableView.baseCellHeight).isActive = true
        
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
    
    override func layoutIfNeeded() {
        self.clipsToBounds = true
        
        cellTitle.textColor = UIColor.niceBlue()
        cellTitle.textAlignment = .left
        
        if (self.isSelected) {
            editButton?.setDefaultProperties()
            editButton?.cornerRadius = 0
            editButton?.backgroundColor = UIColor.niceBlue().withAlphaComponent(0.75)
            editButton?.setTitle("Edit", for: .normal)
            
            startExerciseButton?.setDefaultProperties()
            startExerciseButton?.cornerRadius = 0
            startExerciseButton?.backgroundColor = UIColor.niceGreen().withAlphaComponent(0.75)
            startExerciseButton?.setTitle("Start Exercise!", for: .normal)
            
            self.backgroundColor = UIColor.niceBlue().withAlphaComponent(0.05)
        } else {
            self.backgroundColor = UIColor.white
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    // Set the exercise for this cell
    public func setExercise(exercise: Exercise) {
        // Only make changes if we need to.
        if exercise != self.exercise {
            cellTitle.text = exercise.getName()
            
            self.exercise = exercise
            
            for label in progressionLabels {
                label.removeFromSuperview()
            }
            
            progressionLabels.removeAll()
            editButton?.removeFromSuperview()
            startExerciseButton?.removeFromSuperview()
            
            editButton = PrettyButton()
            startExerciseButton = PrettyButton()
            
            //startWorkoutButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            
            self.addSubview(editButton!)
            self.addSubview(startExerciseButton!)
            
            // Previous view
            var prevLabel: UIView = cellTitle
            
            for progressionMethod in exercise.getProgressionMethods() {
                let progressionMethodLabel = UILabel()
                progressionMethodLabel.text = "- " + progressionMethod.getName()!
                progressionMethodLabel.textColor = UIColor.niceBlue()
                progressionMethodLabel.textAlignment = .left
                self.addSubview(progressionMethodLabel)
                
                // Constraints for this exercise label.
                // Place 10 from left/right of the cell
                // Place 10 below above view, height of 20
                
                progressionMethodLabel.translatesAutoresizingMaskIntoConstraints = false
                
                
                NSLayoutConstraint.createViewBelowViewConstraint(view: progressionMethodLabel,
                                                                 belowView: prevLabel,
                                                                 withPadding: 10).isActive = true
                NSLayoutConstraint(item: self,
                                   attribute: .left,
                                   relatedBy: .equal,
                                   toItem: progressionMethodLabel,
                                   attribute: .left,
                                   multiplier: 1,
                                   constant: -20).isActive = true
                NSLayoutConstraint(item: self,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: progressionMethodLabel,
                                   attribute: .right,
                                   multiplier: 1,
                                   constant: 10).isActive = true
                NSLayoutConstraint.createHeightConstraintForView(view: progressionMethodLabel,
                                                                 height: 20).isActive = true
                
                self.progressionLabels.append(progressionMethodLabel)
                prevLabel = progressionMethodLabel
            }
            
            
            // MARK: Edit Button Constraints
            editButton?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.createViewBelowViewConstraint(view: editButton!,
                                                             belowView: prevLabel,
                                                             withPadding: prevLabel == cellTitle ?
                                                                0 : 26).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: editButton!,
                                                             height: ExercisesTableView.baseCellHeight).isActive = true
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
            
            
            // MARK: Start exercise button constraints
            
            startExerciseButton?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.createViewBelowViewConstraint(view: startExerciseButton!,
                                                             belowView: prevLabel,
                                                             withPadding: prevLabel == cellTitle ?
                                                                0 : 26).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: startExerciseButton!,
                                                             height: WorkoutTableView.baseCellHeight).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: startExerciseButton,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: startExerciseButton,
                               attribute: .width,
                               multiplier: 2,
                               constant: 0).isActive = true
        }
    }
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutIfNeeded()
    }
}
