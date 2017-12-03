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
    
    // The title label for this view
    private let titleLabel: UILabel
    // The table view holding all the data of this past workout
    private let summaryTableView: WorkoutSessionSummaryTableView
    // A button the user should press if we're trying to close this view
    private let closeButton: PrettyButton
    
    // MARK: Init methods
    
    init(workout: Workout?, exercises: List<Exercise>) {
        titleLabel = UILabel()
        summaryTableView = WorkoutSessionSummaryTableView(workout: workout,
                                                          exercises: exercises,
                                                          style: .plain)
        closeButton = PrettyButton()
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(summaryTableView)
        addSubview(closeButton)
        
        closeButton.addTarget(self,
                              action: #selector(buttonPress(sender:)),
                              for: .touchUpInside)
        
        createAndActivateTitleLabelConstraints()
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
        backgroundColor = .niceGray
        
        // Title label
        titleLabel.setDefaultProperties()
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .niceLightBlue
        titleLabel.text = "Workout Summary"
        
        // Close button
        closeButton.setDefaultProperties()
        closeButton.setTitle("Return to Main View",
                             for: .normal)
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch sender {
        case closeButton:
            removeSelfNicelyWithAnimation()
        default:
            fatalError("Button pressed that was not set up")
        }
    }
    
    // MARK: Constraint Functions
    
    // Cling to top, left, right ; height 30
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: 30).isActive = true
    }
    
    // Below title label ; Cling to left, right. Place above the close button
    private func createAndActivateSummaryTableViewConstraints() {
        summaryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: summaryTableView,
                                                         belowView: titleLabel).isActive = true
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
