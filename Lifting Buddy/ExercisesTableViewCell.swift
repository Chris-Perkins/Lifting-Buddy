//
//  ExercisesTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/1/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import SwiftCharts

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // The title for every cell
    private var cellTitle: UILabel
    // The exercise associated with each cell
    private var exercise: Exercise?
    // An indicator on whether or not the cell is expanded
    private var expandImage: UIImageView
    // The labels for every exercise
    private var progressionButtons: [ToggleablePrettyButton]
    
    // the chart we're showing
    private var chart: Chart?
    
    // delegate we call to show the workout
    public var mainViewCellDelegate: WorkoutCellDelegate?
    // delegate to show a view for us
    public var showViewDelegate: ShowViewProtocol?
    
    // The button that allows for exercise editing
    private var editButton: PrettyButton?
    // A button to start the exercise
    private var startExerciseButton: PrettyButton?
    
    // MARK: Init functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.cellTitle = UILabel()
        self.expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        self.progressionButtons = [ToggleablePrettyButton]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(cellTitle)
        self.addSubview(expandImage)
        
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.clipsToBounds = true
        
        cellTitle.textColor = UIColor.niceBlue()
        cellTitle.textAlignment = .left
        
        if (self.isSelected) {
            editButton?.setDefaultProperties()
            editButton?.cornerRadius = 0
            editButton?.backgroundColor = UIColor.niceBlue()
            editButton?.setTitle("Edit", for: .normal)
            
            startExerciseButton?.setDefaultProperties()
            startExerciseButton?.cornerRadius = 0
            startExerciseButton?.backgroundColor = UIColor.niceGreen()
            startExerciseButton?.setTitle("Start Exercise!", for: .normal)
            
            self.backgroundColor = UIColor.niceLightGray()
        } else {
            self.backgroundColor = UIColor.white
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    // Set the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        self.cellTitle.text = exercise.getName()
        
        // Remove all dependent views so we don't get duplicates
        self.removeAllExerciseDependentViews()
        
        self.chart = createChartFromExerciseHistory(exerciseHistory: exercise.getExerciseHistory(),
                                                    timeAmount: TimeAmount.ALLTIME,
                                                    frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: self.frame.width,
                                                                  height: 300))
        self.addSubview(chart!.view)
        self.createAndActivateChartViewConstraints()
        
        self.editButton = PrettyButton()
        self.startExerciseButton = PrettyButton()
        
        // The last view before these (in terms of top to bottom)
        var prevView: UIView = self.chart!.view
        
        for progressionMethod in exercise.getProgressionMethods() {
            let progressionMethodButton = ToggleablePrettyButton()
            progressionMethodButton.setTitle(progressionMethod.getName(), for: .normal)
            progressionMethodButton.setIsToggled(toggled: true)
            progressionMethodButton.setToggleTextColor(color: UIColor.white)
            progressionMethodButton.setDefaultTextColor(color: UIColor.white)
            progressionMethodButton.setToggleViewColor(color:
                getLineColorsForProgressionMethod(progressionMethod: progressionMethod)[0])
            progressionMethodButton.setDefaultViewColor(color: UIColor.niceGray())
            self.addSubview(progressionMethodButton)
            
            // Constraints for this exercise label.
            // Place 10 from left/right of the cell
            // Place 10 below above view, height of 20
            
            progressionMethodButton.translatesAutoresizingMaskIntoConstraints = false
            
            
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: progressionMethodButton,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: progressionMethodButton,
                                                             belowView: prevView,
                                                             withPadding: prevView == self.chart!.view ?
                                                                10 : 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: progressionMethodButton,
                               attribute: .width,
                               multiplier: 3/2,
                               constant: 0).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: progressionMethodButton,
                                                             height: 30).isActive = true
            
            self.progressionButtons.append(progressionMethodButton)
            prevView = progressionMethodButton
        }
        
        self.editButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.startExerciseButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.addSubview(editButton!)
        self.addSubview(startExerciseButton!)
        
        self.createAndActivateEditAndStartButtonConstraints(withPrevView: prevView)
    }
    
    public func setExpandable(expandable: Bool) {
        self.expandImage.alpha = expandable ? 1 : 0
    }
    
    // MARK: View functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutIfNeeded()
    }
    
    
    // Remove all views that change (height-wise or data-wise) depending on the exercise
    private func removeAllExerciseDependentViews() {
        for button in self.progressionButtons {
            button.removeFromSuperview()
        }
        progressionButtons.removeAll()
        self.chart?.view.removeFromSuperview()
        self.chart = nil
        self.editButton?.removeFromSuperview()
        self.startExerciseButton?.removeFromSuperview()
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case (startExerciseButton!):
            self.mainViewCellDelegate?.startWorkout(workout: nil, exercise: self.exercise)
        case editButton!:
            self.showViewDelegate?.showView(view: CreateExerciseView(exercise: self.exercise!, frame: .zero))
        default:
            fatalError("Button press not handled in exercisestableview!")
        }
    }
    
    // MARK: Constraint functions
    
    // Below view top ; indent to left by 10 ; do not overlap expandImage ; height of basecellheight
    private func createAndActivateCellTitleConstraints() {
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
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: ExercisesTableView.baseCellHeight).isActive = true
    }
    
    // Indent from right ; Below self top ; Width 16 ; Height 8.46
    private func createAndActivateExpandImageConstraints() {
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: expandImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: expandImage,
                                                            belowView: self,
                                                            withPadding: 20.77).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage, width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage, height: 8.46).isActive = true
    }
    
    // Center horiz in view ; Width of this view ; Below cell title ; Height 300
    private func createAndActivateChartViewConstraints() {
        self.chart!.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.chart!.view,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.chart!.view,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.chart!.view,
                                                         belowView: self.cellTitle,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.chart!.view,
                                                         height: 300).isActive = true
    }
    
    // Place at bottom of view; take up left, right of view. Height of BaseCellHeight
    private func createAndActivateEditAndStartButtonConstraints(withPrevView: UIView) {
        // MARK: Edit Button Constraints
        self.editButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.editButton!,
                                                         belowView: withPrevView,
                                                         withPadding: withPrevView == self.cellTitle ?
                                                            0 : 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.editButton!,
                                                         height: ExercisesTableView.baseCellHeight).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.editButton,
                           attribute: .left,
                           multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.editButton,
                           attribute: .width,
                           multiplier: 2,
                           constant: 0).isActive = true
        
        
        // MARK: Start exercise button constraints
        
        self.startExerciseButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.startExerciseButton!,
                                                         belowView: withPrevView,
                                                         withPadding: withPrevView == self.cellTitle ?
                                                            0 : 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.startExerciseButton!,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.startExerciseButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.startExerciseButton,
                           attribute: .width,
                           multiplier: 2,
                           constant: 0).isActive = true
    }
}
