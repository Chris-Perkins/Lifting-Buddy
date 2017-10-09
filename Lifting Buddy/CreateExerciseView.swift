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
    
    // name entry label
    private var nameEntryLabel: UILabel
    // where the name goes
    private var nameEntryField: UITextField
    // set/rep label
    private var setRepLabel: UILabel
    // field which contains setentryfield and repentryfield
    private var setRepEntryFieldView: UIView
    // field for set count entry
    private var setEntryField: UITextField
    // field for rep entry
    private var repEntryField: UITextField
    // progressions label
    private var progressionsLabel: UILabel
    // table which holds all of the progressionmethods for this exercise
    private var progressionsTableView: ProgressionsTableView
    // adds a progression method to the tableview
    private var addProgressionTrackerButton: PrettyButton
    // creates the exercise
    private var createExerciseButton: PrettyButton
    // cancels creation
    private var cancelButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(frame: CGRect) {
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        setRepLabel = UILabel()
        setRepEntryFieldView = UIView()
        setEntryField = UITextField()
        repEntryField = UITextField()
        progressionsLabel = UILabel()
        progressionsTableView = ProgressionsTableView()
        addProgressionTrackerButton = PrettyButton()
        createExerciseButton = PrettyButton()
        cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryLabel)
        self.addSubview(nameEntryField)
        self.addSubview(setRepLabel)
        self.addSubview(setRepEntryFieldView)
        setRepEntryFieldView.addSubview(setEntryField)
        setRepEntryFieldView.addSubview(repEntryField)
        self.addSubview(progressionsLabel)
        self.addSubview(progressionsTableView)
        self.addSubview(addProgressionTrackerButton)
        self.addSubview(createExerciseButton)
        self.addSubview(cancelButton)
        
        self.createAndActivateNameEntryLabelConstraints()
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivateSetRepLabelConstraints()
        self.createAndActivateSetRepEntryFieldViewConstraints()
        self.createAndActivateSetEntryFieldConstraints()
        self.createAndActivateRepEntryFieldConstraints()
        self.createAndActivateProgressionsLabelConstraints()
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

        // Name Entry Label
        nameEntryLabel.text = "Name of New Exercise"
        nameEntryLabel.setDefaultProperties()
        
        // Name Entry Field
        nameEntryField.setDefaultProperties()
        nameEntryField.placeholder = "Required: Name of Exercise"
        
        
        // Set/rep entry label
        setRepLabel.setDefaultProperties()
        setRepLabel.text = "Default sets x reps"
        
        // Set entry field
        setEntryField.setDefaultProperties()
        setEntryField.keyboardType = .numberPad
        setEntryField.placeholder = "Set Count"
        
        // Rep entry field
        repEntryField.setDefaultProperties()
        repEntryField.keyboardType = .numberPad
        repEntryField.placeholder = "Rep Count"
        
        
        // Progression Label
        progressionsLabel.setDefaultProperties()
        progressionsLabel.text = "Progression Trackers"
        
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
        
        if nameEntryField.text?.characters.count == 0 {
            fulfilled = false
            
            nameEntryField.backgroundColor = UIColor.niceRed()
            nameEntryField.text = ""
        }
        if !setEntryField.isNumeric() {
            fulfilled = false
            
            setEntryField.backgroundColor = UIColor.niceRed()
            setEntryField.text = ""
        }
        if !repEntryField.isNumeric() {
            fulfilled = false
            
            repEntryField.backgroundColor = UIColor.niceRed()
            repEntryField.text = ""
        }
        for cell in progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell]
        {
            if cell.nameEntryField.text?.characters.count == 0 {
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
        if setEntryField.text?.characters.count != 0 {
            createdExercise.setSetCount(setCount: Int(setEntryField.text!)!)
        } else {
            createdExercise.setSetCount(setCount: 0)
        }
        
        if repEntryField.text?.characters.count != 0 {
            createdExercise.setRepCount(repCount: Int(repEntryField.text!)!)
        } else {
            createdExercise.setRepCount(repCount: 0)
        }
        
        // Add all progression methods from this cell
        for cell in progressionsTableView.getAllCells() as! [ProgressionMethodTableViewCell] {
            let progressionMethod = ProgressionMethod()
            progressionMethod.setName(name: cell.nameEntryField.text!)
            progressionMethod.setUnit(unit: cell.pickUnitButton.titleLabel!.text!)
            
            createdExercise.appendProgressionMethod(progressionMethod: progressionMethod)
        }
        
        return createdExercise
    }
    
    // MARK: Constraints
    
    // center horiz in view ; place below view top ; height 20 ; width of this view - 80
    func createAndActivateNameEntryLabelConstraints() {
        nameEntryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryLabel,
                                                            belowView: self,
                                                            withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: nameEntryLabel,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    // center horiz in view ; place below nameentrylabel ; height 50 ; width of this view
    func createAndActivateNameEntryFieldConstraints() {
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                         belowView: nameEntryLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: nameEntryField,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    // center horiz in view ; place below nameentryfield ; height 20 ; width of this view - 40
    func createAndActivateSetRepLabelConstraints() {
        setRepLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: setRepLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: setRepLabel,
                                                         belowView: nameEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setRepLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: setRepLabel,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true
    }
    
    // center horiz in view ; place below setreplabel ; height 40 ; width of this view - 80
    func createAndActivateSetRepEntryFieldViewConstraints() {
        setRepEntryFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: setRepEntryFieldView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: setRepEntryFieldView,
                                                         belowView: setRepLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setRepEntryFieldView,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: setRepEntryFieldView,
                                                            withCopyView: self, plusWidth: -40).isActive = true
    }
    
    // cling to top,bottom,left of setrepentryfieldview; width of setrepentryfieldview / 2 - 5
    func createAndActivateSetEntryFieldConstraints() {
        setEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: setEntryField,
                                                            belowView: setRepEntryFieldView,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: setEntryField,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: setEntryField,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: setEntryField,
                           attribute: .width,
                           multiplier: 2,
                           constant: 5).isActive = true
    }
    
    // cling to top,bottom,right of setrepentryfieldview; width of setrepentryfieldview / 2 - 5
    func createAndActivateRepEntryFieldConstraints() {
        repEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: repEntryField,
                                                            belowView: setRepEntryFieldView,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: repEntryField,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: repEntryField,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: setRepEntryFieldView,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: repEntryField,
                           attribute: .width,
                           multiplier: 2,
                           constant: 5).isActive = true
    }
    
    // center horiz in view ; place below setrepentryfieldview; height 40 ; width of this view - 80
    func createAndActivateProgressionsLabelConstraints() {
        progressionsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: progressionsLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsLabel,
                                                         belowView: setRepEntryFieldView,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: progressionsLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: progressionsLabel,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    // center horiz in view ; place below progressionslabel ; height default 0 ; width of this view - 40
    func createAndActivateProgressionsTableViewConstraints() {
        progressionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: progressionsTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsTableView,
                                                         belowView: progressionsLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        
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
                                                            plusWidth: -80).isActive = true
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
                                                            plusWidth: -40).isActive = true
    }
}

// MARK: Protocol

protocol CreateExerciseViewDelegate {
    // Pass exercise result from this screen to the delegate
    func finishedWithExercise(exercise: Exercise)
}
