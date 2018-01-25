//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // The height per progression method view
    public static let heightPerProgressionMethodInput = BetterTextField.defaultHeight
    
    private var historyEntry: ExerciseHistoryEntry?
    
    public let titleLabel: UILabel
    public let inputContentView: UIView
    
    private var pgmInputFields: [InputViewHolder]
    
    
    public var exercise: Exercise? {
        didSet {
            inputContentView.removeAllSubviews()
            pgmInputFields.removeAll()
            
            if let exercise = exercise {
                createInputFieldsForExercise(exercise)
            }
            
            layoutSubviews()
        }
    }
    
    // MARK: View init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel       = UILabel()
        inputContentView = UIView()
        pgmInputFields   = [InputViewHolder]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(inputContentView)
        
        createAndActivateTitleLabelConstraints()
        createAndActivateInputContentViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.setDefaultProperties()
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = UIColor.lightestBlackWhiteColor
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        titleLabel.drawText(in: CGRect(x: 10,
                                       y: 0,
                                       width: titleLabel.frame.width - 20,
                                       height: titleLabel.frame.height))
    }
    
    // MARK: View functions
    
    public static func getHeight(forExercise exercise: Exercise) -> CGFloat {
        let pgmHeights = CGFloat(exercise.getProgressionMethods().count) *
                            heightPerProgressionMethodInput
        let baseHeight = UITableViewCell.defaultHeight
        
        return pgmHeights + baseHeight
    }
    
    // MARK: View functions
    
    // create the input fields in the center field
    private func createInputFieldsForExercise(_ exercise: Exercise) {
        var prevView = inputContentView
        
        for progressionMethod in exercise.getProgressionMethods() {
            if progressionMethod.getUnit() != ProgressionMethod.Unit.TIME.rawValue {
                let progressionInput = BetterInputView(args: [(
                    progressionMethod.getName(),
                    progressionMethod.getDefaultValue() ?? progressionMethod.getName(),
                    true
                    )], frame: .zero)
                
                inputContentView.addSubview(progressionInput)
                pgmInputFields.append(progressionInput)
                
                addConstraintsToInputView(view: progressionInput, prevView: prevView)
                
                prevView = progressionInput
            } else {
                let progressionInput = TimeInputField(frame: .zero)
                
                progressionInput.setDefaultValue(progressionMethod.getDefaultValue())
                
                inputContentView.addSubview(progressionInput)
                pgmInputFields.append(progressionInput)
                
                addConstraintsToInputView(view: progressionInput, prevView: prevView)
                
                
                prevView = progressionInput
            }
        }
    }
    
    // MARK: Constraints
    
    // Cling to top, left of self. copy width. Height of default.
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
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: UITableViewCell.defaultHeight
                                                        ).isActive = true
    }
    
    private func createAndActivateInputContentViewConstraints() {
        inputContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: inputContentView,
                                                         belowView: titleLabel).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
    }
    
    // Add the constraints to the an input given the view and the previous view
    private func addConstraintsToInputView(view: UIView, prevView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: inputContentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: inputContentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: prevView,
                           attribute: prevView == inputContentView ? .top : .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: view,
                                                         height: BetterTextField.defaultHeight
            ).isActive = true
    }
}
