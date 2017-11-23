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
    
    // The multiplier of how much the graph should take up
    private static let chartWidthMultiplier: CGFloat = 0.85
    
    // delegate we call to show the workout
    public var mainViewCellDelegate: WorkoutSessionStarter?
    // delegate to show a view for us
    public var showViewDelegate: ShowViewDelegate?
    
    // The title for every cell
    private let cellTitle: UILabel
    // The exercise associated with each cell
    private var exercise: Exercise?
    // An indicator on whether or not the cell is expanded
    private let expandImage: UIImageView
    // a button that absorbs touches to prevent view from collapsing
    private let invisButton: UIButton
    // The view which holds our chart and all associated views
    private var chartFrame: UIView
    // The button that allows for exercise editing
    private let editButton: PrettyButton
    // A button to start the exercise
    private let startExerciseButton: PrettyButton
    
    // the height constraint for our chart frame
    private var chartHeightConstraint: NSLayoutConstraint?
    
    // MARK: Init functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.cellTitle = UILabel()
        self.expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        self.invisButton = UIButton()
        self.chartFrame = UIView()
        self.editButton = PrettyButton()
        self.startExerciseButton = PrettyButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.editButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.startExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.addSubview(self.cellTitle)
        self.addSubview(self.expandImage)
        self.addSubview(self.chartFrame)
        self.addSubview(self.editButton)
        self.addSubview(self.startExerciseButton)
        
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivateChartFrameConstraints()
        self.createAndActivateEditButtonConstraints()
        self.createAndActivateStartButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.chartFrame.layoutSubviews()
        
        self.clipsToBounds = true
        self.chartFrame.clipsToBounds = true
        
        self.cellTitle.textColor = UIColor.niceBlue
        self.cellTitle.textAlignment = .left
        
        if (self.isSelected) {
            self.editButton.setDefaultProperties()
            self.editButton.cornerRadius = 0
            self.editButton.backgroundColor = UIColor.niceBlue
            self.editButton.setTitle("Edit", for: .normal)
            
            self.startExerciseButton.setDefaultProperties()
            self.startExerciseButton.cornerRadius = 0
            self.startExerciseButton.backgroundColor = UIColor.niceGreen
            self.startExerciseButton.setTitle("Start Exercise!", for: .normal)
            
            self.backgroundColor = UIColor.niceLightGray
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        self.cellTitle.text = exercise.getName()
        
        if exercise.getProgressionMethods().count > 0 {
            let chartGraphView = ExerciseChartViewWithToggles(exercise: exercise,
                                                              chartWidth: self.frame.width *
                                                                ExerciseTableViewCell.chartWidthMultiplier)
            self.chartFrame.addSubview(chartGraphView)
            self.chartFrame.backgroundColor = UIColor.niceRed
            
            self.chartHeightConstraint?.constant =
            ExerciseChartViewWithToggles.getNecessaryHeightForExerciseGraph(exercise: exercise)
            chartGraphView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.clingViewToView(view: chartGraphView,
                                               toView: self.chartFrame)
        } else {
            self.chartHeightConstraint?.constant = 0
        }
        
        self.layoutSubviews()
    }
    
    // Sets the expand button constraints
    public func setExpandable(expandable: Bool) {
        self.expandImage.alpha = expandable ? 1 : 0
    }
    
    // MARK: View functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutIfNeeded()
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case startExerciseButton:
            self.mainViewCellDelegate?.startWorkout(workout: nil, exercise: self.exercise)
        case editButton:
            self.showViewDelegate?.showView(view: CreateExerciseView(exercise: self.exercise!, frame: .zero))
        default:
            fatalError("Button press not handled in exercisestableview!")
        }
    }
    
    // MARK: Constraint functions
    
    // Below view top ; indent to left by 10 ; do not overlap expandImage ; height of defaultHeight
    private func createAndActivateCellTitleConstraints() {
        self.cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Indent from right ; Below self top ; Width 16 ; Height 8.46
    private func createAndActivateExpandImageConstraints() {
        self.expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage,
                                                        width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage,
                                                         height: 8.46).isActive = true
    }
    
    private func createAndActivateChartFrameConstraints() {
        self.chartFrame.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.chartFrame,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.chartFrame,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: ExerciseTableViewCell.chartWidthMultiplier
                                                             ).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.chartFrame,
                                                         belowView: self.cellTitle).isActive = true
        
        // Start at 0. Is increased when exercise is set.
        self.chartHeightConstraint = NSLayoutConstraint.createHeightConstraintForView(view: self.chartFrame,
                                                                                      height: 0)
        self.chartHeightConstraint?.isActive = true
    }
    
    // Place at bottom of view, left of view ; width of this view * 0.5 ; Height of default
    private func createAndActivateEditButtonConstraints() {
        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.editButton,
                                                         belowView: self.chartFrame,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.editButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // Place at bottom of view, right of view ; width of this view * 0.5 ; Height of default
    private func createAndActivateStartButtonConstraints() {
        self.startExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.startExerciseButton,
                                                         belowView: self.chartFrame,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.startExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.startExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.startExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
}
