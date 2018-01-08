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
    private let chartFrame: UIView
        // The view that actually stores the exercise chart
        private var chartView: ExerciseChartViewWithToggles?
    // The button that allows for exercise editing
    private let editButton: PrettyButton
    // A button to start the exercise
    private let startExerciseButton: PrettyButton
    
    // the height constraint for our chart frame
    private var chartHeightConstraint: NSLayoutConstraint?
    
    // MARK: Init functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        invisButton = UIButton()
        chartFrame = UIView()
        editButton = PrettyButton()
        startExerciseButton = PrettyButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        editButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        startExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        addSubview(cellTitle)
        addSubview(expandImage)
        addSubview(chartFrame)
        addSubview(editButton)
        addSubview(startExerciseButton)
        
        createAndActivateCellTitleConstraints()
        createAndActivateExpandImageConstraints()
        createAndActivateChartFrameConstraints()
        createAndActivateEditButtonConstraints()
        createAndActivateStartButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        chartFrame.layoutSubviews()
        
        clipsToBounds = true
        chartFrame.clipsToBounds = true
        
        cellTitle.textColor = .niceBlue
        cellTitle.textAlignment = .left
        
        if (isSelected) {
            editButton.setDefaultProperties()
            editButton.setTitle("Edit", for: .normal)
            
            startExerciseButton.setDefaultProperties()
            startExerciseButton.backgroundColor = .niceBlue
            startExerciseButton.setTitle("Start Exercise", for: .normal)
            
            backgroundColor = .lightBlackWhiteColor
        } else {
            backgroundColor = .primaryBlackWhiteColor
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        cellTitle.text = exercise.getName()
        
        if exercise.getProgressionMethods().count > 0 {
            let chartGraphView = ExerciseChartViewWithToggles(exercise: exercise,
                                                              chartWidth: frame.width *
                                                                ExerciseTableViewCell.chartWidthMultiplier)
            chartFrame.addSubview(chartGraphView)
            chartFrame.backgroundColor = .niceRed
            
            chartHeightConstraint?.constant =
                ExerciseChartViewWithToggles.getNecessaryHeightForExerciseGraph(exercise: exercise)
            chartGraphView.translatesAutoresizingMaskIntoConstraints = false
            
            chartView = chartGraphView
            
            NSLayoutConstraint.clingViewToView(view: chartGraphView,
                                               toView: chartFrame)
        } else {
            chartHeightConstraint?.constant = 0
        }
        
        layoutSubviews()
    }
    
    // Sets the expand button constraints
    public func setExpandable(expandable: Bool) {
        expandImage.alpha = expandable ? 1 : 0
    }
    
    // MARK: View functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        if isSelected {
            expandImage.transform = CGAffineTransform(scaleX: 1, y: -1)
            chartView?.createChart()
        } else {
            expandImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            chartView?.destroyChart()
        }
        
        layoutSubviews()
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case startExerciseButton:
            guard let mainViewController = viewController() as? MainViewController else {
                fatalError("view controller is now main view controller?")
            }
            mainViewController.startSession(workout: nil, exercise: exercise!)
        case editButton:
            guard let showViewDelegate = showViewDelegate else {
                fatalError("ShowViewDelegate not set for CreateExerciseView")
            }
            let createExerciseView = CreateExerciseView(exercise: exercise, frame: .zero)
            createExerciseView.showViewDelegate = showViewDelegate
            showViewDelegate.showView(createExerciseView)
        default:
            fatalError("Button press not handled in exercisestableview!")
        }
    }
    
    // MARK: Constraint functions
    
    // Below view top ; indent to left by 10 ; do not overlap expandImage ; height of defaultHeight
    private func createAndActivateCellTitleConstraints() {
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
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
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage,
                                                        width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage,
                                                         height: 8.46).isActive = true
    }
    
    private func createAndActivateChartFrameConstraints() {
        chartFrame.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: chartFrame,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: chartFrame,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: ExerciseTableViewCell.chartWidthMultiplier
            ).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: chartFrame,
                                                         belowView: cellTitle).isActive = true
        
        // Start at 0. Is increased when exercise is set.
        chartHeightConstraint = NSLayoutConstraint.createHeightConstraintForView(view: chartFrame,
                                                                                 height: 0)
        chartHeightConstraint?.isActive = true
    }
    
    // Place at bottom of view, left of view ; width of this view * 0.5 ; Height of default
    private func createAndActivateEditButtonConstraints() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: editButton,
                                                         belowView: chartFrame,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // Place at bottom of view, right of view ; width of this view * 0.5 ; Height of default
    private func createAndActivateStartButtonConstraints() {
        startExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: startExerciseButton,
                                                         belowView: chartFrame,
                                                         withPadding: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: startExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
}
