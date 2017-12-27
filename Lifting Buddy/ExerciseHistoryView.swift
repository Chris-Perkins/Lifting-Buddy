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
    private let exerciseHistoryTableView: ExerciseHistoryTableView
    private let closeButton: PrettyButton
    
    init(exercise: Exercise, frame: CGRect) {
        self.exercise = exercise
        exerciseHistoryTableView = ExerciseHistoryTableView(forExercise: exercise,
                                                            style: .plain)
        closeButton = PrettyButton()
        
        super.init(frame: frame)
        
        // This is done to ensure that the history may not be opened in multiple views
        ExerciseHistoryView.exercisesBeingViewed.insert(exercise)
        
        addSubview(exerciseHistoryTableView)
        addSubview(closeButton)
        
        exerciseHistoryTableView.setData(exercise.getExerciseHistory())
        closeButton.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)
        
        createAndActivateExerciseHistoryTableViewConstraints()
        createAndActivateCloseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.setDefaultProperties()
        closeButton.setTitle("Close", for: .normal)
    }
    
    // MARK: Event functions
    
    @objc internal func closeButtonPress() {
        exercise.recalculateProgressionMethodMaxValues()
        // We can now free the exercise from being viewed.
        ExerciseHistoryView.exercisesBeingViewed.remove(exercise)
        
        removeSelfNicelyWithAnimation()
    }
    
    // MARK: Constraints
    
    private func createAndActivateExerciseHistoryTableViewConstraints() {
        exerciseHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseHistoryTableView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
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
