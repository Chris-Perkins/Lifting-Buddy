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
    private var exerciseNameLabel: UILabel
    // The edit button for this cell
    private var editButton: PrettyButton
    // The exercise associated with this cell
    private var exercise: Exercise?
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.exerciseNameLabel = UILabel()
        self.editButton = PrettyButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(exerciseNameLabel)
        self.addSubview(editButton)
        
        editButton.addTarget(self, action: #selector(editPress(sender:)), for: .touchUpInside)
        
        
        /*
         * Comments for below code: Name label takes up 75% of the view
         * starting from the left. For example: N = Name Label, E = Edit button
         * Layout is: NNNE
         */
        self.createAndActivateExerciseNameLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.clipsToBounds = true
        
        exerciseNameLabel.setDefaultProperties()
        
        editButton.setDefaultProperties()
        editButton.removeOverlayView()
        editButton.animationTimeInSeconds = 0.1
        editButton.setOverlayStyle(style: .FADE)
        editButton.setTitle("Edit", for: .normal)
    }
    
    // MARK: Public methods
    
    // Sets the exercise for this view
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        self.exerciseNameLabel.text = exercise.getName()
    }
    
    // MARK: Event Functions
    
    @objc func editPress(sender: UIButton) {
        self.showViewDelegate?.showView(view: CreateExerciseView(exercise: self.exercise!,
                                                                 frame: .zero))
    }
    
    // MARK: Constraint functions
    
    // Cling to top, bottom, left. Width of this view * 0.66
    private func createAndActivateExerciseNameLabelConstraints() {
        self.exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseNameLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseNameLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseNameLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 2/3).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseNameLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
    }
    
    // Cling to top, bottom, right of this view ; cling to left of exercisenamelabel
    private func createAndActivateEditButtonConstraints() {
        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: self.exerciseNameLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.editButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
