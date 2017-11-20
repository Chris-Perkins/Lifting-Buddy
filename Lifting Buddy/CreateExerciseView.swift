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

class CreateExerciseView: UIScrollView {
    
    // MARK: View properties
    
    // delegate which receives information after creation
    public var dataDelegate: CreateExerciseViewDelegate?
    
    // Padding between views
    private let viewPadding: CGFloat = 20.0
    
    // the exercise we're editing
    private var editingExercise: Exercise?
    
    // Labels the view
    private var createExerciseLabel: UILabel
    // where the name goes
    private var nameEntryField: BetterTextField
    // field for set count entry
    private var setEntryField: BetterTextField
    // table which holds all of the progressionmethods for this exercise
    private var progressionsTableView: ProgressionsMethodTableView
    // adds a progression method to the tableview
    private var addProgressionTrackerButton: PrettyButton
    // creates the exercise
    private var createExerciseButton: PrettyButton
    // cancels creation
    private var cancelButton: PrettyButton
    
    // MARK: Init overrides
    
    init(exercise: Exercise? = nil, frame: CGRect) {
        self.editingExercise = exercise
        
        self.createExerciseLabel = UILabel()
        self.nameEntryField = BetterTextField(defaultString: "Required: Name", frame: .zero)
        self.setEntryField = BetterTextField(defaultString: "Optional: Set Count", frame: .zero)
        self.progressionsTableView = ProgressionsMethodTableView()
        self.addProgressionTrackerButton = PrettyButton()
        self.createExerciseButton = PrettyButton()
        self.cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(createExerciseLabel)
        self.addSubview(nameEntryField)
        self.addSubview(setEntryField)
        self.addSubview(progressionsTableView)
        self.addSubview(addProgressionTrackerButton)
        self.addSubview(createExerciseButton)
        self.addSubview(cancelButton)
        
        self.createAndActivateCreateExerciseLabelConstraints()
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivateSetEntryFieldConstraints()
        self.createAndActivateProgressionsTableViewConstraints()
        self.createAndActivateAddProgressionTrackerButtonConstraints()
        self.createAndActivateCreateExeciseButtonConstraints()
        self.createAndActivateCancelButtonConstraints()
        
        self.addProgressionTrackerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.createExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.setViewPropertiesBasedOnExercise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // self stuff
        self.backgroundColor = UIColor.niceGray
        self.contentSize.height = createExerciseButton.frame.maxY + 50 + viewPadding
        
        // Label
        self.createExerciseLabel.setDefaultProperties()
        self.createExerciseLabel.text = self.editingExercise == nil ? "Create New Exercise" : "Edit Exercise"
        
        // Name Entry Field
        self.nameEntryField.setDefaultProperties()
        self.nameEntryField.setLabelTitle(title: "Name")
        
        // Set entry field
        self.setEntryField.setDefaultProperties()
        self.setEntryField.setLabelTitle(title: "Sets")
        self.setEntryField.textfield.keyboardType = .numberPad
        
        // Progressions Table View
        // Prevent clipping as we can click and drag cells
        self.progressionsTableView.clipsToBounds = false
        self.progressionsTableView.isScrollEnabled = false
        self.progressionsTableView.backgroundColor = UIColor.clear
        
        // Add progression method button
        self.addProgressionTrackerButton.setDefaultProperties()
        self.addProgressionTrackerButton.setTitle("Add Progression Tracker", for: .normal)
        
        // Create exercise button
        self.createExerciseButton.setTitle(self.editingExercise == nil ? "Create Exercise" : "Save Exercise",
                                           for: .normal)
        self.createExerciseButton.setDefaultProperties()
        
        // Cancel Button
        self.cancelButton.setDefaultProperties()
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.backgroundColor = UIColor.niceRed
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: UIButton) {
        switch(sender){
        case self.addProgressionTrackerButton:
            self.progressionsTableView.appendDataToTableView(data: ProgressionMethod())
            break
        case self.createExerciseButton:
            // Send info to delegate, animate up then remove self
            if self.requirementsFulfilled() {
                let exerciseCreated: Exercise = self.saveAndReturnExercise()
                
                // Send data to delegate
                self.dataDelegate?.finishedWithExercise(exercise: exerciseCreated)
                self.removeSelfNicelyWithAnimation()
            }
            break
        case self.cancelButton:
            self.removeSelfNicelyWithAnimation()
            break
        default:
            fatalError("User pressed a button that does not exist in switch?")
        }
    }
    
    // MARK: Private functions
    
    // Starts the views off based on the exercise received
    private func setViewPropertiesBasedOnExercise() {
        if let exercise = self.editingExercise {
            self.nameEntryField.textfield.text = exercise.getName()!
            self.setEntryField.textfield.text = String(describing: exercise.getSetCount())
            
            for progressionMethod in exercise.getProgressionMethods() {
                self.progressionsTableView.appendDataToTableView(data: progressionMethod)
            }
        } else {
            let repProgressionMethod = ProgressionMethod()
            repProgressionMethod.setName(name: ProgressionMethod.Unit.REPS.rawValue)
            repProgressionMethod.setUnit(unit: ProgressionMethod.Unit.REPS.rawValue)
            
            self.progressionsTableView.appendDataToTableView(data: repProgressionMethod)
        }
    }
    
    // Checks if the requirements for this exercise are fulfilled
    // Requirements:
    // Non-empty name
    // Integer or empty set/rep count
    // Non-empty name and unit for every progression method
    private func requirementsFulfilled() -> Bool {
        var fulfilled = true
        
        if self.nameEntryField.textfield.text?.count == 0 {
            fulfilled = false
            
            self.nameEntryField.textfield.backgroundColor = UIColor.niceRed
            self.nameEntryField.textfield.text = ""
        }
        if !self.setEntryField.textfield.isNumeric {
            fulfilled = false
            
            self.setEntryField.textfield.backgroundColor = UIColor.niceRed
            self.setEntryField.textfield.text = ""
        }
        for cell in self.progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]
        {
            if cell.nameEntryField.text?.count == 0 {
                fulfilled = false
                
                cell.nameEntryField.backgroundColor = UIColor.niceRed
            }
            if cell.pickUnitButton.titleLabel?.text == "Required: Unit" {
                fulfilled = false
                
                cell.pickUnitButton.backgroundColor = UIColor.niceRed
            }
        }
        
        return fulfilled
    }
    
    // Creates an exercise object with info from this screen
    private func saveAndReturnExercise() -> Exercise {
        let createdExercise = self.editingExercise ?? Exercise()
        
        createdExercise.setName(name: nameEntryField.text!)
        
        // Set set and rep count
        if setEntryField.textfield.text?.count != 0 {
            createdExercise.setSetCount(setCount: Int(setEntryField.textfield.text!)!)
        } else {
            createdExercise.setSetCount(setCount: 0)
        }
        
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
        
        // If this is a new exercise, create it!
        if self.editingExercise == nil {
            let realm = try! Realm()
            try! realm.write {
                realm.add(createdExercise)
            }
        }
        
        return createdExercise
    }
    
    // MARK: Constraints
    
    // center horiz in view; cling to top; width of this view ; height 30
    private func createAndActivateCreateExerciseLabelConstraints() {
        self.createExerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: viewPadding).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createExerciseLabel,
                                                         height: 30).isActive = true
    }
    
    // center horiz in view ; place below nameentrylabel ; height 50 ; width of this view * 4/5
    private func createAndActivateNameEntryFieldConstraints() {
        self.nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.nameEntryField,
                                                            belowView: self.createExerciseLabel,
                                                            withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.nameEntryField,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
    }
    
    // cling to top,bottom,left of setentryfieldview; width of self - 40
    private func createAndActivateSetEntryFieldConstraints() {
        self.setEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.setEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint(item: self.nameEntryField,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.setEntryField,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding / 2).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.setEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.setEntryField,
                                                         height: 50).isActive = true
    }
    
    // center horiz in view ; place below progressionslabel ; height default 0 ; width of this view - 40
    private func createAndActivateProgressionsTableViewConstraints() {
        self.progressionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.progressionsTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.progressionsTableView,
                                                         belowView: self.setEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        
        // Assign table view height constraint
        self.progressionsTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: self.progressionsTableView,
                                                             height: 0)
        self.progressionsTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.progressionsTableView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
    }
    
    // place below progressionstableview ; height 50 ; cling left and right to progressionstableview
    private func createAndActivateAddProgressionTrackerButtonConstraints() {
        self.addProgressionTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.addProgressionTrackerButton,
                                                         belowView: self.progressionsTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addProgressionTrackerButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addProgressionTrackerButton,
                                                             withCopyView: self.progressionsTableView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addProgressionTrackerButton,
                                                             withCopyView: self.progressionsTableView,
                                                             attribute: .right).isActive = true
    }
    
    // center horiz in view ; place below addprogressiontrackerbutton ; height 50 ; width of this view - 50
    private func createAndActivateCreateExeciseButtonConstraints() {
        self.createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.createExerciseButton,
                                                         belowView: self.addProgressionTrackerButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createExerciseButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createExerciseButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // center horiz in view ; place below createExerciseButton; height 30 ; width of createExerciseButton - 40
    private func createAndActivateCancelButtonConstraints() {
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.cancelButton,
                                                         belowView: self.createExerciseButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self.createExerciseButton,
                                                             attribute: .width).isActive = true
    }
}

// MARK: Protocol

protocol CreateExerciseViewDelegate {
    // Pass exercise result from this screen to the delegate
    func finishedWithExercise(exercise: Exercise)
}
