//
//  ExerciseHistoryView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/26/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseHistoryView: UIView {
    
    // The exercises currently being viewed
    public static var exercisesBeingViewed = Set<Exercise>()
    
    // The exercise being viewed
    private let exercise: Exercise
    // Displays at the top of the view. Just lets user know where they are
    private let exerciseLabel: UILabel
    // The tableview for the history
    private let exerciseHistoryTableView: ExerciseHistoryTableView
    // Button to close this view
    private let closeButton: PrettyButton
    
    init(exercise: Exercise, frame: CGRect) {
        self.exercise = exercise
        exerciseLabel = UILabel()
        exerciseHistoryTableView = ExerciseHistoryTableView(forExercise: exercise,
                                                            style: .plain)
        closeButton = PrettyButton()
        
        super.init(frame: frame)
        
        // This is done to ensure that the history may not be opened in multiple views
        ExerciseHistoryView.exercisesBeingViewed.insert(exercise)
        
        addSubview(exerciseLabel)
        addSubview(exerciseHistoryTableView)
        addSubview(closeButton)
        
        exerciseHistoryTableView.setData(exercise.getExerciseHistory())
        closeButton.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)
        
        createAndActivateExerciseLabelConstraints()
        createAndActivateExerciseHistoryTableViewConstraints()
        createAndActivateCloseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Exercise Label
        exerciseLabel.setDefaultProperties()
        exerciseLabel.textColor = UILabel.titleLabelTextColor
        exerciseLabel.backgroundColor = UILabel.titleLabelBackgroundColor
        exerciseLabel.text = "History for \(exercise.getName()!)"
        
        // Close button
        closeButton.setDefaultProperties()
        closeButton.setTitle(NSLocalizedString("Button.Close", comment: ""), for: .normal)
    }
    
    // MARK: Event functions
    
    @objc internal func closeButtonPress() {
        exercise.recalculateProgressionMethodMaxValues()
        // We can now free the exercise from being viewed.
        ExerciseHistoryView.exercisesBeingViewed.remove(exercise)
        
        removeSelfNicelyWithAnimation()
    }
    
    // MARK: Constraints
    
    // Cling to top, left, right of self ; Height of default
    private func createAndActivateExerciseLabelConstraints() {
        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: exerciseLabel,
                                                         height: UILabel.titleLabelHeight).isActive = true
    }
    
    // Cling to left, right of self ; Place below exercise label ; Place above closeButton
    private func createAndActivateExerciseHistoryTableViewConstraints() {
        exerciseHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: exerciseHistoryTableView,
                                                         belowView: exerciseLabel).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseHistoryTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseHistoryTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: closeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: exerciseHistoryTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to left, right, bottom of self ; Height of PrettyButton default
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
