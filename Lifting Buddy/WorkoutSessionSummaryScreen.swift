//
//  WorkoutSessionSummaryView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class WorkoutSessionSummaryView: UIView {
    
    // MARK: View properties
    
    // The delegate for who's handling when this session ends
    public var workoutSessionDelegate: WorkoutSessionStarter?
    
    // Please make sure the below views add up to something below 1, or you'll face weird constraints.
    // any remaining space will go towards the gain label.
    // The width compared to this view's width
    public static let pgmLabelWidthOfView: CGFloat = 0.5
    //  The width of dataView compared to this view's width
    public static let newDataLabelWidthOfView: CGFloat = 0.25
    
    // The view which contains all header information
    private let headerView: UIView
    // The title label for this view
    private let titleLabel: UILabel
    // The value label for what we did during the workout
    private let valueLabel: UILabel
    // The label for gain/less
    private let gainLabel: UILabel
    // The table view holding all the data of this past workout
    private let summaryTableView: WorkoutSessionSummaryTableView
    // A button the user should press if we're trying to close this view
    private let closeButton: PrettyButton
    
    private var workout: Workout?
    private var exercises: List<Exercise>
    
    // MARK: Init methods
    
    init(workout: Workout?, exercises: List<Exercise>) {
        self.workout = workout
        self.exercises = exercises
        
        headerView = UIView()
        titleLabel = UILabel()
        valueLabel = UILabel()
        gainLabel = UILabel()
        summaryTableView = WorkoutSessionSummaryTableView(workout: workout,
                                                          exercises: exercises,
                                                          style: .plain)
        closeButton = PrettyButton()
        
        super.init(frame: .zero)
        
        addSubview(headerView)
            headerView.addSubview(titleLabel)
            headerView.addSubview(valueLabel)
            headerView.addSubview(gainLabel)
        addSubview(summaryTableView)
        addSubview(closeButton)
        
        closeButton.addTarget(self,
                              action: #selector(buttonPress(sender:)),
                              for: .touchUpInside)
        
        createAndActivateHeaderViewConstraints()
        createAndActivateTitleLabelConstraints()
        createAndActivateValueLabelConstraints()
        createAndActivateGainLabelConstraints()
        createAndActivateSummaryTableViewConstraints()
        createAndActivateCloseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This view's layout
        backgroundColor = .lightestBlackWhiteColor
        
        // Header View
        headerView.backgroundColor = UILabel.titleLabelBackgroundColor
        
        // Title label
        titleLabel.setDefaultProperties()
        titleLabel.textColor = UILabel.titleLabelTextColor
        titleLabel.text = "Tracker Name"
        
        // Value label
        valueLabel.setDefaultProperties()
        valueLabel.textColor = UILabel.titleLabelTextColor
        valueLabel.text = "Value"
        
        // Gain label constraints
        gainLabel.setDefaultProperties()
        gainLabel.textColor = UILabel.titleLabelTextColor
        gainLabel.text = "vs. Max"
        
        // Close button
        closeButton.setDefaultProperties()
        closeButton.setTitle("End Session",
                             for: .normal)
    }
    
    // MARK: Custom functions
    
    public func endSession() {
        workoutSessionDelegate?.endSession(workout: workout, exercises: exercises)
        removeSelfNicelyWithAnimation()
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch sender {
        case closeButton:
            workoutSessionDelegate?.endSession(workout: workout, exercises: exercises)
            removeSelfNicelyWithAnimation()
        default:
            fatalError("Button pressed that was not set up")
        }
    }
    
    // MARK: Constraint Functions
    
    // Cling to top, left, right ; height 30
    private func createAndActivateHeaderViewConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: 30).isActive = true
    }
    
    // Cling to top, left, bottom of headerview ; width of pgmLabel
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .width,
                                                             multiplier: WorkoutSessionSummaryView.pgmLabelWidthOfView
                                                            ).isActive = true
    }
    
    // Cling to top, bottom of headerview ; width of newdatalabelwidth ; cling to right of titlelabel
    private func createAndActivateValueLabelConstraints() {
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: valueLabel,
                                                             withCopyView: headerView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: valueLabel,
                                                             withCopyView: headerView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: valueLabel,
                                                             withCopyView: headerView,
                                                             attribute: .width,
                                                             multiplier: WorkoutSessionSummaryView.newDataLabelWidthOfView
                                                            ).isActive = true
        NSLayoutConstraint(item: titleLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: valueLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to top, bottom, right of headerview ; cling to right of valuelabel
    private func createAndActivateGainLabelConstraints() {
        gainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: gainLabel,
                                                             withCopyView: headerView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: gainLabel,
                                                             withCopyView: headerView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: gainLabel,
                                                             withCopyView: headerView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: valueLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: gainLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Below title label ; Cling to left, right. Place above the close button
    private func createAndActivateSummaryTableViewConstraints() {
        summaryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: summaryTableView,
                                                         belowView: headerView).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: summaryTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: summaryTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: closeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: summaryTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        
    }
    
    // Cling to bottom, right, left ; height of pretty button default height
    private func createAndActivateCloseButtonConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: closeButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        
    }
}
