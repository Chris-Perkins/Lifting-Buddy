//
//  ExercisesView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/29/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ExercisesView: UIView {
    
    // MARK: View properties
    
    // Notified when we pick an exercise
    public var exercisePickerDelegate: ExercisePickerDelegate?
    
    // Whether or not we're simply selecting an exercise
    private let selectingExercise: Bool
    
    // Whether or not we've loaded the view
    private var loaded: Bool = false
    
    // The workouts for this view
    private let exerciseTableView: ExercisesTableView
    // The view where our buttons go
    private let footerView: UIView
    // The button to create this workout
    private let createExerciseButton: PrettyButton
    // A button to cancel this view (only visible if selecting exercise)
    private let cancelButton: PrettyButton
    
    // MARK: View inits
    
    required init(selectingExercise: Bool = false, frame: CGRect) {
        self.selectingExercise = selectingExercise
        let realm = try! Realm()
        
        let exercises = realm.objects(Exercise.self)
        
        exerciseTableView = ExercisesTableView(exercises: AnyRealmCollection(exercises),
                                               selectingExercise: selectingExercise,
                                               style: UITableViewStyle.plain)
        footerView = UIView()
        createExerciseButton = PrettyButton()
        cancelButton = PrettyButton()
        
        
        super.init(frame: frame)
        
        addSubview(footerView)
            footerView.addSubview(createExerciseButton)
            footerView.addSubview(cancelButton)
        addSubview(exerciseTableView)
        
        createAndActivateFooterViewConstraints()
        createAndActivateCancelButtonConstraints()
        createAndActivateCreateExerciseButtonConstraints()
        createAndActivateExerciseTableViewConstraints()
        
        exerciseTableView.exercisePickerDelegate = self
        
        createExerciseButton.addTarget(self,
                                       action: #selector(showCreateExerciseView(sender:)),
                                       for: .touchUpInside)
        cancelButton.addTarget(self,
                               action: #selector(removeSelf),
                               for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .lightestBlackWhiteColor
        
        createExerciseButton.setDefaultProperties()
        createExerciseButton.setTitle(selectingExercise ? "New Exercise" : "Create New Exercise",
                                      for: .normal)
        
        if selectingExercise {
            cancelButton.setDefaultProperties()
            cancelButton.backgroundColor = .niceRed
            cancelButton.setTitle("Cancel", for: .normal)
        } else {
            cancelButton.alpha = 0
        }
        
        exerciseTableView.reloadData()
    }
    
    // MARK: View functions
    
    // Just removes this view
    @objc func removeSelf() {
        removeSelfNicelyWithAnimation()
    }
    
    public func selectExercise(exercise: Exercise) {
        guard let indexOfExercise = exerciseTableView.getSortedData().index(of: exercise) else {
            fatalError("Exercise selected that did not exist!")
        }
        let indexPath = IndexPath(row: indexOfExercise, section: 0)
        exerciseTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
    }
    
    // MARK: Event functions
    
    @objc func showCreateExerciseView(sender: PrettyButton) {
        let createExerciseView: CreateExerciseView = CreateExerciseView(frame: .zero)
        
        createExerciseView.dataDelegate = self
        
        showView(createExerciseView)
    }
    
    // MARK: Constraint functions
    
    // Cling to bottom, left, right of view ; height of default prettybutton height
    private func createAndActivateFooterViewConstraints() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: footerView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: footerView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: footerView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: footerView,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // Cling to top, left, right of this view ; bottom of this view @ createButton
    private func createAndActivateExerciseTableViewConstraints() {
        exerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: footerView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: exerciseTableView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to right, top, bottom of footer ; place to right of cancelbutton
    private func createAndActivateCreateExerciseButtonConstraints() {
        createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: footerView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: cancelButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: createExerciseButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: footerView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: footerView,
                                                             attribute: .bottom).isActive = true
    }
    
    // cling to left, top, bottom of this view ; width 0.5 if selectingExercise else 0
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: footerView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: footerView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: footerView,
                                                             attribute: .bottom).isActive = true
        if selectingExercise {
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: footerView,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
        } else {
            NSLayoutConstraint.createWidthConstraintForView(view: cancelButton,
                                                            width: 0).isActive = true
        }
    }
}

extension ExercisesView: ExercisePickerDelegate {
    // when we select an exercise, return it.
    func didSelectExercise(exercise: Exercise) {
        exercisePickerDelegate?.didSelectExercise(exercise: exercise)
        removeSelfNicelyWithAnimation()
    }
}

extension ExercisesView: CreateExerciseViewDelegate {
    // Called when a workout is created from this view
    func finishedWithExercise(exercise: Exercise) {
        // if we're selecting an exercise, return the one we just made.
        if selectingExercise {
            exercisePickerDelegate?.didSelectExercise(exercise: exercise)
            removeSelfNicelyWithAnimation()
        } else {
            exerciseTableView.reloadData()
            exerciseTableView.layoutSubviews()
        }
    }
}

extension ExercisesView: ShowViewDelegate {
    // Shows a view over this one
    func showView(_ view: UIView) {
        addSubview(view)
        UIView.slideView(view, overView: self)
    }
}
