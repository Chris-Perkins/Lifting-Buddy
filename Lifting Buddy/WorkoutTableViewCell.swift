//
//  WorkoutTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // The title for every cell
    private var cellTitle: UILabel
    // The workout associated with each cell
    private var workout: Workout?
    // The fire image displayed by streak
    private var fireImage: UIImageView
    // The label saying how many days we're on streak
    private var streakLabel: UILabel
    // An indicator on whether or not the cell is expanded
    private var expandImage: UIImageView
    // The labels for every exercise
    private var exerciseLabels: [UILabel]
    
    // A delegate notified whenever we start a workout
    public var workoutCellDelegate: WorkoutCellDelegate?
    // A delegate to show a view for us
    public var showViewDelegate: ShowViewProtocol?
    
    // The button stating whether or not we want to edit this workout
    private var editButton: PrettyButton?
    // A button to start the workout
    private var startWorkoutButton: PrettyButton?
    private var exercises = List<Exercise>()
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        fireImage = UIImageView(image: #imageLiteral(resourceName: "Fire"))
        streakLabel = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        exerciseLabels = [UILabel]()
        
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
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
        
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
        
        
        // Don't show the streak if there is no streak
        if workout != nil && workout!.getCurSteak() > 0 {
            streakLabel.text = String(describing: workout!.getCurSteak())
            streakLabel.textColor = UIColor.niceRed()
            
            streakLabel.alpha = 1
            fireImage.alpha = 1
        } else {
            streakLabel.alpha = 0
            fireImage.alpha = 0
        }
        
        if (self.isSelected) {
            editButton?.setDefaultProperties()
            editButton?.backgroundColor = UIColor.niceBlue()
            editButton?.setTitle("Edit", for: .normal)
            
            startWorkoutButton?.setDefaultProperties()
            startWorkoutButton?.cornerRadius = 0
            startWorkoutButton?.backgroundColor = UIColor.niceGreen()
            startWorkoutButton?.setTitle("Start Workout!", for: .normal)
            
            self.backgroundColor = UIColor.niceLightGray()
        } else {
            self.backgroundColor = (workout?.getIfTodayWorkout())! ? UIColor.niceLightGreen() : UIColor.white
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    // Set the workout for this cell
    public func setWorkout(workout: Workout) {
        // Only make changes if we need to.
        // TODO: Determine when a change is made so we don't have to be dumb in checking.
        //if workout != self.workout {
        self.cellTitle.text = workout.getName()
        
        self.workout = workout
        
        for label in exerciseLabels {
            label.removeFromSuperview()
        }
        self.exerciseLabels.removeAll()
        self.editButton?.removeFromSuperview()
        self.startWorkoutButton?.removeFromSuperview()
        
        self.editButton = PrettyButton()
        self.startWorkoutButton = PrettyButton()
        
        self.editButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.startWorkoutButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.addSubview(editButton!)
        self.addSubview(startWorkoutButton!)
        
        // Previous view
        var prevLabel: UIView = cellTitle
        
        self.exercises = workout.getExercises()
        for exercise in self.exercises {
            let exerLabel = UILabel()
            exerLabel.text = "- " + exercise.getName()!
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
                               constant: -20).isActive = true
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
        
        
        // MARK: Edit Button Constraints
        editButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: editButton!,
                                                         belowView: prevLabel,
                                                         withPadding: prevLabel == cellTitle ?
                                                            0 : 26).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editButton!,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
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
        
        
        // MARK: Start workout button constraints
        
        startWorkoutButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: startWorkoutButton!,
                                                         belowView: prevLabel,
                                                         withPadding: prevLabel == cellTitle ?
                                                         0 : 26).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: startWorkoutButton!,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
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
        //}
    }
    
    // Returns this workout
    public func getWorkout() -> Workout? {
        return self.workout
    }
    
    // Mark: view functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutIfNeeded()
    }
    
    // MARK: Event functions
    
    // Notified on a button press
    @objc func buttonPress(sender: UIButton) {
        switch(sender) {
        case startWorkoutButton!:
            self.workoutCellDelegate?.startWorkout(workout: self.workout, exercise: nil)
            break
        case editButton!:
            self.showViewDelegate?.showView(view: CreateWorkoutView(workout: self.workout!, frame: .zero))
            break
        default:
            fatalError("User pressed a button that does not exist?")
        }
    }
}

@objc protocol WorkoutCellDelegate {
    /*
     * Notified when a workout is starting
     */
    func startWorkout(workout: Workout?, exercise: Exercise?)
    /*
     * Notified when a workout is ending
     */
    @objc optional func endWorkout()
}
