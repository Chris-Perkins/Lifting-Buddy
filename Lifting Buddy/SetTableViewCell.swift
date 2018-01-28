//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SetTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // The height per progression method view
    public static let heightPerProgressionMethodInput = BetterTextField.defaultHeight
    // The ratio compared to this view that the complete button should take up
    public static let completeButtonWidthRatio = BetterTextField.labelWidthRatio
    
    // The delegate we use to inform of status changed (completion button press)
    public var statusDelegate: SetTableViewCellDelegate?
    
    /*
     * We need a separate entry for the height constraint as it needs to be modified
     * If we don't do this, the console throws warnings about breaking constraints.
     *  Yes, it's annoying.
    */
    public var inputViewHeightConstraint: NSLayoutConstraint?
    
    public let titleLabel: UILabel
    public let completeButton: ToggleablePrettyButton
    // View where the set entries take place
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
    public var historyEntry: ExerciseHistoryEntry?
    
    // MARK: View init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel       = UILabel()
        completeButton   = ToggleablePrettyButton()
        inputContentView = UIView()
        pgmInputFields   = [InputViewHolder]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(completeButton)
        addSubview(inputContentView)
        
        createAndActivateTitleLabelConstraints()
        createAndActivateCompleteButtonConstraints()
        createAndActivateInputContentViewConstraints()
        
        completeButton.addTarget(self, action: #selector(completeButtonPress(_:)), for: .touchUpInside)
        // We send the completeSessionNotification if the session ends for any reason.
        // This can happen when the application terminates or the complete session button is press.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveExerciseHistoryInformation),
                                               name: completeSessionNotification,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Title label
        titleLabel.setDefaultProperties()
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = completeButton.isToggled ?
                                        .niceLightGreen : .lightestBlackWhiteColor
        
        // Complete Button
        completeButton.setDefaultProperties()
        completeButton.setDefaultText(text: "×")
        completeButton.setDefaultTextColor(color: .white)
        completeButton.setDefaultViewColor(color: .niceBlue)
        completeButton.setToggleText(text: "✓")
        completeButton.setToggleTextColor(color: .white)
        completeButton.setToggleViewColor(color: .niceGreen)
        
        for inputViewHolder in pgmInputFields {
            for inputView in inputViewHolder.getInputViews() {
                if completeButton.isToggled {
                    inputView.setLabelColors(backgroundColor: .niceLightGreen)
                    inputView.isUserInteractionEnabled = false
                    inputView.layoutSubviews()
                } else {
                    inputView.setLabelColors()
                    inputView.isUserInteractionEnabled = true
                    inputView.layoutSubviews()
                }
            }
        }
    }
    
    // MARK: View functions
    
    public static func getHeight(forExercise exercise: Exercise) -> CGFloat {
        let pgmHeights = CGFloat(exercise.getProgressionMethods().count) *
                            heightPerProgressionMethodInput
        let baseHeight = UITableViewCell.defaultHeight
        
        return pgmHeights + baseHeight
    }
    
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
    
    // Gets a history piece from all the fields
    func getExercisePiecesFromInputFields() -> List<RLMExercisePiece> {
        let exerciseList = List<RLMExercisePiece>()
        
        for (index, pgm) in exercise!.getProgressionMethods().enumerated() {
            let exercisePiece = RLMExercisePiece()
            
            exercisePiece.progressionMethod = pgm
            exercisePiece.value = pgmInputFields[index].getValue()
            
            exerciseList.append(exercisePiece)
        }
        
        return exerciseList
    }
    
    // MARK: View actions
    
    @objc private func completeButtonPress(_ button: ToggleablePrettyButton) {
        statusDelegate?.setStatusUpdate(toCompletionStatus: button.isToggled)
        
        for (index, pgm) in exercise!.getProgressionMethods().enumerated() {
            pgm.setDefaultValue(defaultValue: pgmInputFields[index].getValue())
        }
    }
    
    @objc func saveExerciseHistoryInformation() {
        let realm = try! Realm()
        if let historyEntry = historyEntry,
            completeButton.isToggled {
            
            try! realm.write {
                historyEntry.date = Date()
                historyEntry.exerciseInfo = getExercisePiecesFromInputFields()
                
                realm.add(historyEntry)
            }
            
            exercise?.appendExerciseHistoryEntry(historyEntry)
        }
    }
    
    // MARK: Constraints
    
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: titleLabel,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: titleLabel,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: completeButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: SetTableViewCell.completeButtonWidthRatio
                                                            ).isActive = true
    }
    
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
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: UITableViewCell.defaultHeight
                                                        ).isActive = true
    }
    
    // Cling to left, right of self; place below self
    private func createAndActivateInputContentViewConstraints() {
        inputContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: inputContentView,
                                                         belowView: titleLabel).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        inputViewHeightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: inputContentView,
                                                             height: 0)
        inputViewHeightConstraint?.isActive = true
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
