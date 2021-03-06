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
    
    public var setDate: Date?
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        for (index, inputViewHolder) in pgmInputFields.enumerated() {
            if !completeButton.isToggled {
                inputViewHolder.setDefaultValue(
                    exercise?.getProgressionMethods()[index].getDefaultValue())
            }
            
            for inputView in inputViewHolder.getInputViews() {
                if completeButton.isToggled {
                    inputView.setLabelColors(backgroundColor: .niceLightGreen)
                    inputView.textfield.resignFirstResponder()
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
            if progressionMethod.getUnit() != ProgressionMethod.Unit.time.rawValue {
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
    
    // Determines if we can save exercises
    private func determineIfCanSaveFields() -> Bool {
        var returnVal = true
        for inputView in pgmInputFields {
            returnVal = returnVal && inputView.areFieldsValid()
        }
        
        return returnVal
    }
    
    // MARK: View actions
    
    @objc private func completeButtonPress(_ button: ToggleablePrettyButton) {
        // If we can't save the fields, don't do anything.
        if !determineIfCanSaveFields() {
            completeButton.setIsToggled(toggled: false)
            return
        }
        
        // Lets us set the default values for everything
        for (index, pgm) in exercise!.getProgressionMethods().enumerated() {
            let savedValue = pgmInputFields[index].getValue()
            
            // If the button is toggled, save the information immediately.
            if button.isToggled {
                pgm.setDefaultValue(defaultValue: savedValue)
                
                if let oldMax = pgm.getMaxValue(), savedValue.floatValue! > oldMax &&
                    // This lets us check if the value entered is greater than any for the same pgm
                    // In this session.
                    (entriesPerPGMInSession[pgm] == nil || entriesPerPGMInSession[pgm]!.count == 0 ||
                        entriesPerPGMInSession[pgm]!.max()! < savedValue.floatValue!) {
                    MessageQueue.shared.append(Message(type: .newBest,
                                                       identifier: pgm.getName(),
                                                       value: pgm.getDisplayValue(forValue: savedValue.floatValue!)))
                }
                
                if entriesPerPGMInSession[pgm] == nil {
                    entriesPerPGMInSession[pgm] = [Float]()
                }
                entriesPerPGMInSession[pgm]!.append(savedValue.floatValue!)
            } else {
                // We cycle through to delete whatever value was just un-saved.
                for (index, value) in entriesPerPGMInSession[pgm]!.enumerated() {
                    if value == savedValue.floatValue! {
                        entriesPerPGMInSession[pgm]?.remove(at: index)
                        break
                    }
                }
            }
        }
        
        statusDelegate?.setStatusUpdate(toCompletionStatus: button.isToggled)
        
        saveExerciseHistoryInformation()
    }
    
    // Note: this can save out of order.
    // If user saves their sets out of order, it will be stored out of order.
    // This is a pretty hacky fix.
    @objc func saveExerciseHistoryInformation() {
        let realm = try! Realm()
        if let historyEntry = historyEntry {
            if completeButton.isToggled {
                try! realm.write {
                    historyEntry.date = setDate
                    historyEntry.exerciseInfo = getExercisePiecesFromInputFields()
                    
                    realm.add(historyEntry)
                }
                
                exercise?.insertExerciseHistoryEntry(historyEntry)
            } else {
                exercise?.removeExerciseHistoryEntry(historyEntry)
                
                // We remake the history entry since the previous was deleted/invalidated.
                self.historyEntry = ExerciseHistoryEntry()
            }
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
