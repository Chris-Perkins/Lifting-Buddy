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
    
    // where the name goes
    private var nameEntryField: BetterTextField
    // field for set count entry
    private var setEntryField: BetterTextField
    // field for rep entry
    private var repEntryField: BetterTextField
    // table which holds all of the progressionmethods for this exercise
    private var progressionsTableView: ProgressionsMethodTableView
    // adds a progression method to the tableview
    private var addProgressionTrackerButton: PrettyButton
    // creates the exercise
    private var createExerciseButton: PrettyButton
    // cancels creation
    private var cancelButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(frame: CGRect) {
        nameEntryField = BetterTextField(defaultString: "Required: Name of Exercise", frame: .zero)
        setEntryField = BetterTextField(defaultString: "Optional: Default Set Count", frame: .zero)
        repEntryField = BetterTextField(defaultString: "Optional: Default Rep Count", frame: .zero)
        progressionsTableView = ProgressionsMethodTableView()
        addProgressionTrackerButton = PrettyButton()
        createExerciseButton = PrettyButton()
        cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryField)
        self.addSubview(setEntryField)
        self.addSubview(repEntryField)
        self.addSubview(progressionsTableView)
        self.addSubview(addProgressionTrackerButton)
        self.addSubview(createExerciseButton)
        self.addSubview(cancelButton)
        
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivateSetEntryFieldConstraints()
        self.createAndActivateRepEntryFieldConstraints()
        self.createAndActivateProgressionsTableViewConstraints()
        self.createAndActivateAddProgressionTrackerButtonConstraints()
        self.createAndActivateCreateExeciseButtonConstraints()
        self.createAndActivateCancelButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // self stuff
        self.backgroundColor = UIColor.niceGray()
        self.contentSize.height = createExerciseButton.frame.maxY + 50 + viewPadding
        
        // Name Entry Field
        nameEntryField.setDefaultProperties()
        nameEntryField.setLabelTitle(title: "Name")
        
        // Set entry field
        setEntryField.setDefaultProperties()
        setEntryField.setLabelTitle(title: "Sets")
        setEntryField.textfield.keyboardType = .numberPad
        
        // Rep entry field
        repEntryField.setDefaultProperties()
        repEntryField.setLabelTitle(title: "Reps")
        repEntryField.textfield.keyboardType = .numberPad
        
        // Progressions Table View
        // Prevent clipping as we can click and drag cells
        progressionsTableView.clipsToBounds = false
        progressionsTableView.isScrollEnabled = false
        progressionsTableView.backgroundColor = UIColor.clear
        
        // Add progression method button
        addProgressionTrackerButton.setDefaultProperties()
        addProgressionTrackerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        addProgressionTrackerButton.setOverlayColor(color: UIColor.niceYellow())
        addProgressionTrackerButton.setOverlayStyle(style: .FADE)
        addProgressionTrackerButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        addProgressionTrackerButton.setTitle("Add Progression Tracker", for: .normal)
        addProgressionTrackerButton.setTitleColor(UIColor.niceBlue(), for: .normal)
        addProgressionTrackerButton.setTitleColor(UIColor.white, for: .highlighted)
        
        // Create exercise button
        createExerciseButton.setTitle("Create Exercise", for: .normal)
        createExerciseButton.setDefaultProperties()
        createExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        // Cancel Button
        cancelButton.setDefaultProperties()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.niceRed()
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: UIButton) {
        switch(sender){
        case addProgressionTrackerButton:
            progressionsTableView.appendDataToTableView(data: ProgressionMethod())
            break
        case createExerciseButton:
            // Send info to delegate, animate up then remove self
            if self.requirementsFulfilled() {
                let exerciseCreated: Exercise = createExerciseFromData()
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(exerciseCreated)
                }
                
                // Send data to delegate
                self.dataDelegate?.finishedWithExercise(exercise: exerciseCreated)
                self.removeSelfNicelyWithAnimation()
            }
            break
        case cancelButton:
            self.removeSelfNicelyWithAnimation()
            break
        default:
            fatalError("User pressed a button that does not exist in switch?")
        }
    }
    
    // MARK: Private functions
    
    // Checks if the requirements for this exercise are fulfilled
    // Requirements:
    // Non-empty name
    // Integer or empty set/rep count
    // Non-empty name and unit for every progression method
    private func requirementsFulfilled() -> Bool {
        var fulfilled = true
        
        if nameEntryField.textfield.text?.count == 0 {
            fulfilled = false
            
            nameEntryField.textfield.backgroundColor = UIColor.niceRed()
            nameEntryField.textfield.text = ""
        }
        if !setEntryField.textfield.isNumeric {
            fulfilled = false
            
            setEntryField.textfield.backgroundColor = UIColor.niceRed()
            setEntryField.textfield.text = ""
        }
        if !repEntryField.textfield.isNumeric {
            fulfilled = false
            
            repEntryField.textfield.backgroundColor = UIColor.niceRed()
            repEntryField.textfield.text = ""
        }
        for cell in progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]
        {
            if cell.nameEntryField.text?.count == 0 {
                fulfilled = false
                
                cell.nameEntryField.backgroundColor = UIColor.niceRed()
            }
            if cell.pickUnitButton.titleLabel?.text == "Required: Unit" {
                fulfilled = false
                
                cell.pickUnitButton.backgroundColor = UIColor.niceRed()
            }
        }
        
        return fulfilled
    }
    
    // Creates an exercise object with info from this screen
    private func createExerciseFromData() -> Exercise {
        let createdExercise = Exercise()
        
        createdExercise.setName(name: nameEntryField.text!)
        
        // Set set and rep count
        if setEntryField.textfield.text?.count != 0 {
            createdExercise.setSetCount(setCount: Int(setEntryField.textfield.text!)!)
        } else {
            createdExercise.setSetCount(setCount: 0)
        }
        
        if repEntryField.textfield.text?.count != 0 {
            createdExercise.setRepCount(repCount: Int(repEntryField.textfield.text!)!)
        } else {
            createdExercise.setRepCount(repCount: 0)
        }
        let progressionMethodRep = ProgressionMethod()
        progressionMethodRep.setName(name: "Reps")
        progressionMethodRep.setUnit(unit: "Reps")
        progressionMethodRep.setDefaultValue(defaultValue: (repEntryField.textfield.text?.isEmpty)! ?
                                                            "Rep Count" : repEntryField.textfield.text)
        progressionMethodRep.setIndex(index: 0)
        
        createdExercise.appendProgressionMethod(progressionMethod: progressionMethodRep)
        
        // Add all progression methods from this cell
        for (index, cell) in (progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]).enumerated() {
            let progressionMethod = ProgressionMethod()
            progressionMethod.setName(name: cell.nameEntryField.text!)
            progressionMethod.setUnit(unit: cell.pickUnitButton.titleLabel!.text!)
            progressionMethod.setIndex(index: index + 1)
            
            createdExercise.appendProgressionMethod(progressionMethod: progressionMethod)
        }
        
        return createdExercise
    }
    
    // MARK: Constraints
    
    // center horiz in view ; place below nameentrylabel ; height 50 ; width of this view * 4/5
    func createAndActivateNameEntryFieldConstraints() {
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryField,
                                                            belowView: self,
                                                            withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: nameEntryField,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true
    }
    
    // cling to top,bottom,left of setrepentryfieldview; width of setrepentryfieldview / 2 - 5
    func createAndActivateSetEntryFieldConstraints() {
        setEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: setEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint(item: nameEntryField,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: setEntryField,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding / 2).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: setEntryField,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setEntryField,
                                                         height: 50).isActive = true
    }
    
    // cling to top,bottom,right of setrepentryfieldview; width of setrepentryfieldview / 2 - 5
    func createAndActivateRepEntryFieldConstraints() {
        repEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: repEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint(item: setEntryField,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: repEntryField,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding / 2).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: repEntryField,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: repEntryField,
                                                         height: 50).isActive = true
    }
    
    // center horiz in view ; place below progressionslabel ; height default 0 ; width of this view - 40
    func createAndActivateProgressionsTableViewConstraints() {
        progressionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: progressionsTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsTableView,
                                                         belowView: repEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        
        // Assign table view height constraint
        progressionsTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: progressionsTableView,
                                                             height: 0)
        progressionsTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createWidthCopyConstraintForView(view: progressionsTableView,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true
    }
    
    // place below progressionstableview ; height 50 ; cling left and right to progressionstableview
    func createAndActivateAddProgressionTrackerButtonConstraints() {
        addProgressionTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: addProgressionTrackerButton,
                                                         belowView: progressionsTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addProgressionTrackerButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint(item: progressionsTableView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: addProgressionTrackerButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: progressionsTableView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: addProgressionTrackerButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // center horiz in view ; place below addprogressiontrackerbutton ; height 50 ; width of this view - 50
    func createAndActivateCreateExeciseButtonConstraints() {
        createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: createExerciseButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createExerciseButton,
                                                         belowView: addProgressionTrackerButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createExerciseButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: createExerciseButton,
                                                            withCopyView: self,
                                                            plusWidth: -50).isActive = true
    }
    
    // center horiz in view ; place below createExerciseButton; height 30 ; width of createExerciseButton - 40
    func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: cancelButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: cancelButton,
                                                         belowView: createExerciseButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: cancelButton,
                                                            withCopyView: createExerciseButton,
                                                            plusWidth: 0).isActive = true
    }
}

// MARK: Protocol

protocol CreateExerciseViewDelegate {
    // Pass exercise result from this screen to the delegate
    func finishedWithExercise(exercise: Exercise)
}
