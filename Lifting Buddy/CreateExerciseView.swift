//
//  CreateExerciseView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CDAlertView

class CreateExerciseView: UIScrollView {
    
    // MARK: View properties
    
    // Returns whether or not we're currently editing an exercise rather than creating
    public var isEditingExercise: Bool {
        if let _ = editingExercise {
            return true
        }
        return false
    }
    
    // delegate which receives information after creation
    public var dataDelegate: CreateExerciseViewDelegate?
    // delegate to show a view for us
    public var showViewDelegate: ShowViewDelegate?
    
    // the exercise we're editing
    private var editingExercise: Exercise?
    
    // Padding between views
    private let viewPadding: CGFloat = 20.0
    
    // Labels the view
    private let createExerciseLabel: UILabel
    // where the name goes
    private let nameEntryField: BetterTextField
    // field for set count entry
    private let setEntryField: BetterTextField
    // table which holds all of the progressionmethods for this exercise
    private let progressionsTableView: ProgressionsMethodTableView
    // adds a progression method to the tableview
    private let addProgressionTrackerButton: PrettyButton
    // A button which lets us view the exercisehistory for the exercise
    private let editExerciseHistoryButton: PrettyButton
    // creates the exercise
    private let createExerciseButton: PrettyButton
    // cancels creation
    private let cancelButton: PrettyButton
    
    // MARK: Init overrides
    
    init(exercise: Exercise? = nil, frame: CGRect) {
        editingExercise = exercise
        
        createExerciseLabel = UILabel()
        nameEntryField = BetterTextField(defaultString: NSLocalizedString("ExerciseView.Textfield.Name",
                                                                          comment: ""),
                                         frame: .zero)
        setEntryField = BetterTextField(defaultString: NSLocalizedString("ExerciseView.Textfield.SetCount",
                                                                         comment: ""),
                                        frame: .zero)
        progressionsTableView = ProgressionsMethodTableView()
        addProgressionTrackerButton = PrettyButton()
        editExerciseHistoryButton = PrettyButton()
        createExerciseButton = PrettyButton()
        cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(createExerciseLabel)
        addSubview(nameEntryField)
        addSubview(setEntryField)
        addSubview(progressionsTableView)
        addSubview(addProgressionTrackerButton)
        addSubview(editExerciseHistoryButton)
        addSubview(createExerciseButton)
        addSubview(cancelButton)
        
        createAndActivateCreateExerciseLabelConstraints()
        createAndActivateNameEntryFieldConstraints()
        createAndActivateSetEntryFieldConstraints()
        createAndActivateProgressionsTableViewConstraints()
        createAndActivateAddProgressionTrackerButtonConstraints()
        createAndActivateCreateExerciseButtonConstraints()
        createAndActivateCancelButtonConstraints()
        
        if isEditingExercise {
            createAndActivateEditExerciseHistoryButtonConstraints()
        }
        
        addProgressionTrackerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        editExerciseHistoryButton.addTarget(  self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        createExerciseButton.addTarget(       self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        cancelButton.addTarget(               self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        setViewPropertiesBasedOnExercise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // self stuff
        backgroundColor = .lightestBlackWhiteColor
        contentSize.height = createExerciseButton.frame.maxY + 50 + viewPadding
        
        // Label
        createExerciseLabel.setDefaultProperties()
        createExerciseLabel.backgroundColor = UILabel.titleLabelBackgroundColor
        createExerciseLabel.textColor = UILabel.titleLabelTextColor
        createExerciseLabel.text = isEditingExercise ?
            NSLocalizedString("EditExerciseView.Label.EditExercise", comment: "") :
            NSLocalizedString("EditExerciseView.Label.NewExercise", comment: "")
        
        // Name Entry Field
        nameEntryField.setLabelTitle(title: NSLocalizedString("Button.Name", comment: ""))
        
        // Set entry field
        setEntryField.setLabelTitle(title: NSLocalizedString("Info.Sets", comment: ""))
        setEntryField.setIsNumeric(isNumeric: true)
        
        // Progressions Table View
        // Prevent clipping as we can click and drag cells
        // Prevent interaction if we can't modify progressionMethods
        progressionsTableView.clipsToBounds = false
        progressionsTableView.isScrollEnabled = false
        progressionsTableView.backgroundColor = .clear
        progressionsTableView.isUserInteractionEnabled = editingExercise?.canModifyCoreProperties ?? true
        progressionsTableView.alpha = (editingExercise?.canModifyCoreProperties ?? true) ? 1 : 0.75
        
        // Edit Exercise History Button
        editExerciseHistoryButton.setDefaultProperties()
        editExerciseHistoryButton.setTitle(NSLocalizedString("EditExerciseView.Button.EditHistory",
                                                             comment: ""),
                                           for: .normal)
        // If we can't view the history, set color to light blue to indicate the button won't work.
        if editingExercise == nil || editingExercise!.historyIsBeingViewed {
            editExerciseHistoryButton.backgroundColor = UIColor.niceLightBlue
        }
        
        // Add progression method button
        addProgressionTrackerButton.setDefaultProperties()
        addProgressionTrackerButton.backgroundColor =
                        (editingExercise?.canModifyCoreProperties ?? true) ?
                            .niceBlue : .niceLightBlue
            
        addProgressionTrackerButton.setTitle(NSLocalizedString("EditExerciseView.Button.AddTracker",
                                                               comment: ""),
                                             for: .normal)
        
        // Create exercise button
        createExerciseButton.setTitle(isEditingExercise ?
            NSLocalizedString("EditExerciseView.Button.Save",   comment: ""):
            NSLocalizedString("EditExerciseView.Button.Create", comment: ""),
                                      for: .normal)
        createExerciseButton.setDefaultProperties()
        
        // Cancel Button
        cancelButton.setDefaultProperties()
        cancelButton.setTitle(NSLocalizedString("Button.Cancel", comment: ""), for: .normal)
        cancelButton.backgroundColor = .niceRed
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: UIButton) {
        checkIfExerciseInvalidated()
        
        // Dismisses the keyboard from all possible textfields
        endEditing(true)
        
        switch(sender){
        case addProgressionTrackerButton:
            if editingExercise?.canModifyCoreProperties ?? true {
                progressionsTableView.appendDataToTableView(data: ProgressionMethod())
            } else {
                let alert = CDAlertView(title: NSLocalizedString(  "Message.CannotAddPGM.Title", comment: ""),
                                        message: NSLocalizedString("Message.CannotAddPGM.Desc", comment: ""),
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            }
        case createExerciseButton:
            // Send info to delegate, animate up then remove self
            if requirementsFulfilled() {
                let exerciseCreated: Exercise = saveAndReturnExercise()
                
                MessageQueue.append(Message(type: editingExercise == nil ? .ObjectCreated : .ObjectSaved,
                                            identifier: exerciseCreated.getName(),
                                            value: nil))
                
                // Send data to delegate to inform that we've changed something
                dataDelegate?.finishedWithExercise(exercise: exerciseCreated)
                
                removeSelfNicelyWithAnimation()
            }
        case cancelButton:
            // Just close.
            removeSelfNicelyWithAnimation()
        case editExerciseHistoryButton:
            if let exercise = editingExercise, !exercise.historyIsBeingViewed {
                guard let showViewDelegate = showViewDelegate else {
                    fatalError("ExerciseHistory called to view, but could not be viewed!")
                }
                showViewDelegate.showView(ExerciseHistoryView(exercise: exercise, frame: .zero))
            }
            else {
                let alertTitle = NSLocalizedString("Message.CannotViewHistory.Title", comment: "")
                var alertMessage: String?
                
                if editingExercise?.historyIsBeingViewed == true {
                    alertMessage = NSLocalizedString("Message.CannotViewHistory.DescMultLocations",
                                                     comment: "")
                } else {
                    alertMessage = NSLocalizedString("Message.CannotViewHistory.DescNotSaved", comment: "")
                }
                
                // Otherwise, we are creating an exercise. tell the user we can't display anything
                let alert = CDAlertView(title: alertTitle,
                                        message: alertMessage,
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            }
        default:
            fatalError("User pressed a button that does not exist in switch?")
        }
    }
    
    // MARK: Private functions
    
    // Starts the views off based on the exercise received
    private func setViewPropertiesBasedOnExercise() {
        if let exercise = editingExercise {
            nameEntryField.textfield.text = exercise.getName()!
            setEntryField.textfield.text = String(describing: exercise.getSetCount())
            
            for progressionMethod in exercise.getProgressionMethods() {
                progressionsTableView.appendDataToTableView(data: progressionMethod)
            }
        } else {
            let repProgressionMethod = ProgressionMethod()
            repProgressionMethod.setName(name: ProgressionMethod.Unit.REPS.rawValue)
            repProgressionMethod.setUnit(unit: ProgressionMethod.Unit.REPS.rawValue)
            
            progressionsTableView.appendDataToTableView(data: repProgressionMethod)
        }
    }
    
    // Checks if the requirements for this exercise are fulfilled
    /* Requirements:
         Non-empty name
         Integer or empty set/rep count
         Non-empty name and unit for every progression method
    */
    private func requirementsFulfilled() -> Bool {
        var fulfilled = true
        
        if editingExercise?.isInvalidated ?? false {
            fulfilled = false
        }
        
        if nameEntryField.textfield.text?.count == 0 {
            fulfilled = false
            
            nameEntryField.textfield.backgroundColor = .niceRed
            nameEntryField.textfield.text = ""
        }
        if !setEntryField.textfield.isNumeric {
            fulfilled = false
            
            setEntryField.textfield.backgroundColor = .niceRed
            setEntryField.textfield.text = ""
        }
        for cell in progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]
        {
            if cell.nameEntryField.text?.count == 0 {
                fulfilled = false
                
                cell.nameEntryField.backgroundColor = .niceRed
            }
            if cell.curSelect == -1 {
                fulfilled = false
                
                cell.pickUnitButton.backgroundColor = .niceRed
            }
        }
        
        return fulfilled
    }
    
    // Creates an exercise object with info from this screen
    private func saveAndReturnExercise() -> Exercise {
        let createdExercise = editingExercise ?? Exercise()
        
        createdExercise.setName(name: nameEntryField.text!)
        
        // Set set and rep count
        if setEntryField.textfield.text?.count != 0 {
            createdExercise.setSetCount(setCount: Int(setEntryField.textfield.text!)!)
        } else {
            createdExercise.setSetCount(setCount: 0)
        }
        
        // If we can modify core properties
        if editingExercise?.canModifyCoreProperties ?? true {
            // Progression Methods that we need to delete from history
            var progressionMethodsToDelete = Set(createdExercise.getProgressionMethods())
            
            createdExercise.removeProgressionMethods()
            // Add all progression methods from this cell
            for (index, cell) in (progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]).enumerated() {
                let progressionMethod = cell.saveAndReturnProgressionMethod()
                progressionMethod.setIndex(index: index)
                
                // do not delete anything still in the exercise
                progressionMethodsToDelete.remove(progressionMethod)
                
                createdExercise.appendProgressionMethod(progressionMethod: progressionMethod)
            }
            
            createdExercise.removeProgressionMethodsFromHistory(progressionMethodsToDelete: progressionMethodsToDelete)
        }
        
        // If this is a new exercise, create it!
        if !isEditingExercise {
            let realm = try! Realm()
            try! realm.write {
                realm.add(createdExercise)
            }
        }
        
        return createdExercise
    }
    
    // Determines if the exercise was invalidated.
    // If it was, hide the view and display an error dialog.
    private func checkIfExerciseInvalidated() {
        // If the exercise was deleted from another screen,
        // We have to close this view so we don't error out.
        if editingExercise?.isInvalidated == true {
            let alert = CDAlertView(title: NSLocalizedString("Message.ExerciseDeleted.Title", comment: ""),
                                    message: NSLocalizedString("Message.ExerciseDeleted.Desc", comment: ""),
                                    type: CDAlertViewType.error)
            alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue,
                                                handler: nil))
            alert.show()
            
            self.removeFromSuperview()
        }
    }
    
    // MARK: Constraints
    
    // Cling to left, top of self ; width of this view ; height of title
    private func createAndActivateCreateExerciseLabelConstraints() {
        createExerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createExerciseLabel,
                                                         height: UILabel.titleLabelHeight).isActive = true
    }
    
    // center horiz in view ; place below nameentrylabel ; height of default height ; width of this view - 40
    private func createAndActivateNameEntryFieldConstraints() {
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                         belowView: createExerciseLabel,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                         height: BetterTextField.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
    }
    
    // center horiz ; cling to bottom of nameEntry ; width of self - 40 ; height of default height
    private func createAndActivateSetEntryFieldConstraints() {
        setEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint(item: nameEntryField,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: setEntryField,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding / 2).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setEntryField,
                                                         height: BetterTextField.defaultHeight).isActive = true
    }
    
    // center horiz in view ; place below progressionslabel ; height default 0 ; width of this view - 40
    private func createAndActivateProgressionsTableViewConstraints() {
        progressionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionsTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsTableView,
                                                         belowView: setEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        
        // Assign table view height constraint
        progressionsTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: progressionsTableView,
                                                             height: 0)
        progressionsTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionsTableView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
    }
    
    // place below progressionstableview ; height of default height ; cling left and right to progressionstableview
    private func createAndActivateAddProgressionTrackerButtonConstraints() {
        addProgressionTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: addProgressionTrackerButton,
                                                         belowView: progressionsTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addProgressionTrackerButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addProgressionTrackerButton,
                                                             withCopyView: progressionsTableView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addProgressionTrackerButton,
                                                             withCopyView: progressionsTableView,
                                                             attribute: .right).isActive = true
    }
    
    // center horiz in view ; place below addprogressiontrackerbutton ; height default ; width of this view - 50
    private func createAndActivateEditExerciseHistoryButtonConstraints() {
        editExerciseHistoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editExerciseHistoryButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: editExerciseHistoryButton,
                                                         belowView: addProgressionTrackerButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editExerciseHistoryButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editExerciseHistoryButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // center horiz in view ; place below editexercisehistorybutton ; height 50 ; width of this view - 50
    private func createAndActivateCreateExerciseButtonConstraints() {
        createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createExerciseButton,
                                                         belowView: isEditingExercise ? editExerciseHistoryButton : addProgressionTrackerButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // center horiz in view ; place below createExerciseButton; height 30 ; width of createExerciseButton - 40
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: cancelButton,
                                                         belowView: createExerciseButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: createExerciseButton,
                                                             attribute: .width).isActive = true
    }
}
