//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class EditExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // A protocol to show a view
    public var showViewDelegate: ShowViewDelegate?
    
    // The exercise title for this cell
    private let exerciseView: LabelWithPrettyButtonView
    // The exercise associated with this cell
    private var exercise: Exercise?
    
    // MARK: Init overrides
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        exerciseView = LabelWithPrettyButtonView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(exerciseView)
        
        exerciseView.button.addTarget(self,
                                      action: #selector(editPress(sender:)),
                                      for: .touchUpInside)
        
        
        createAndActivateExerciseViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .lightBlackWhiteColor
        clipsToBounds = true
        
        exerciseView.label.setDefaultProperties()
        exerciseView.label.font = UIFont.systemFont(ofSize: 18.0)
        
        exerciseView.button.setDefaultProperties()
        exerciseView.button.setTitle(NSLocalizedString("Button.Edit", comment: ""), for: .normal)
    }
    
    // MARK: Public methods
    
    // Sets the exercise for this view
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        exerciseView.label.text = exercise.getName()
    }
    
    // MARK: Event Functions
    
    @objc func editPress(sender: UIButton) {
        
        guard let showViewDelegate = showViewDelegate else {
            fatalError("ShowViewDelegate not set for CreateExercisePicker")
        }
        let createExerciseView = CreateExerciseView(exercise: exercise,
                                                    frame: .zero)
        createExerciseView.showViewDelegate = showViewDelegate
        showViewDelegate.showView(createExerciseView)
    }
    
    // MARK: Constraint functions
    
    // Cling to this view
    private func createAndActivateExerciseViewConstraints() {
        NSLayoutConstraint.clingViewToView(view: exerciseView,
                                           toView: self)
    }
}
