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
    let viewPadding: CGFloat = 20.0
    public var dataDelegate: CreateExerciseViewDelegate?
    private var nameEntryLabel: UILabel
    private var nameEntryField: UITextField
    private var setRepLabel: UILabel
    private var setEntryField: UITextField
    private var repEntryField: UITextField
    private var progressionsLabel: UILabel
    private var progressionsTableView: ProgressionsTableView
    private var addProgressionTrackerButton: PrettyButton
    private var createExerciseButton: PrettyButton
    private var prevCellCount = -1
    
    // MARK: Init overrides
    
    override init(frame: CGRect) {
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        setRepLabel = UILabel()
        setEntryField = UITextField()
        repEntryField = UITextField()
        progressionsLabel = UILabel()
        progressionsTableView = ProgressionsTableView()
        addProgressionTrackerButton = PrettyButton()
        createExerciseButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryLabel)
        self.addSubview(nameEntryField)
        self.addSubview(setRepLabel)
        self.addSubview(progressionsLabel)
        self.addSubview(progressionsTableView)
        self.addSubview(addProgressionTrackerButton)
        self.addSubview(createExerciseButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        if prevCellCount == -1 {
            self.backgroundColor = UIColor.niceGray()
            self.layer.zPosition = 100
            
            // MARK: Name Entry Label
            nameEntryLabel.translatesAutoresizingMaskIntoConstraints = false
            nameEntryLabel.text = "Name of New Exercise"
            nameEntryLabel.setDefaultProperties()
            
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryLabel,
                                                             height: 20).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryLabel,
                                                            width: self.frame.width - 40).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryLabel,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryLabel,
                                                                belowView: self,
                                                                withPadding: viewPadding).isActive = true
            
            // MARK: Name Entry Field
            nameEntryField.translatesAutoresizingMaskIntoConstraints = false
            nameEntryField.setDefaultProperties()
            nameEntryField.placeholder = "Required: Name"
            
            /*
             * Center in view, place below the above frame, and give height/width of 40
             */
            NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                             height: 40).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: nameEntryField,
                                                            width: self.frame.width - 80).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                             belowView: nameEntryLabel,
                                                             withPadding: viewPadding / 2).isActive = true
            
            
            // MARK: Set/rep entry label
            setRepLabel.translatesAutoresizingMaskIntoConstraints = false
            setRepLabel.setDefaultProperties()
            setRepLabel.text = "Default sets x reps (empty for no default)"
            
            /*
             * Center in view, place below name entry field. Height = 40, width of this frame's width - 40
             */
            NSLayoutConstraint.createHeightConstraintForView(view: setRepLabel, height: 20).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: setRepLabel,
                                                            width: self.frame.width - 40).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: setRepLabel,
                                                             belowView: nameEntryField,
                                                             withPadding: viewPadding * 1.5).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: setRepLabel,
                                                                            inView: self).isActive = true
            
            // MARK: Set entry field
            setEntryField = UITextField(frame: CGRect(x: 20,
                                                      y: viewPadding * 3.5 + 80,
                                                      width: (self.frame.width - 40) / 2 - 5,
                                                      height: 40))
            setEntryField.setDefaultProperties()
            setEntryField.keyboardType = .numberPad
            setEntryField.placeholder = "Number of Sets"
            self.addSubview(setEntryField)
            
            // MARK: Rep entry field
            repEntryField = UITextField(frame: CGRect(x: self.frame.width / 2 + 2.5,
                                                      y: viewPadding * 3.5 + 80,
                                                      width: (self.frame.width - 40) / 2 - 2.5,
                                                      height: 40))
            repEntryField.setDefaultProperties()
            repEntryField.keyboardType = .numberPad
            repEntryField.placeholder = "Number of Reps"
            self.addSubview(repEntryField)
            
            
            // MARK: Progression Label
            progressionsLabel.translatesAutoresizingMaskIntoConstraints = false
            progressionsLabel.setDefaultProperties()
            progressionsLabel.text = "Progression Trackers"
            
            /*
             * Center in view, place below the set/rep entry frame, and give height/width of 40
             */
            NSLayoutConstraint.createHeightConstraintForView(view: progressionsLabel,
                                                             height: 40).isActive = true
            NSLayoutConstraint.createWidthConstraintForView(view: progressionsLabel,
                                                            width: self.frame.width - 80).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: progressionsLabel,
                                                                            inView: self).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsLabel,
                                                             belowView: repEntryField,
                                                             withPadding: viewPadding * 1.5).isActive = true

            
            // MARK: Progressions Table View
            // MARK: Exercise Table View
            
            // Prevent clipping as we can click and drag cells
            progressionsTableView.clipsToBounds = false
            progressionsTableView.isScrollEnabled = false
            progressionsTableView.backgroundColor = UIColor.clear
            
            progressionsTableView.translatesAutoresizingMaskIntoConstraints = false
            progressionsTableView.heightConstraint =
                NSLayoutConstraint.createHeightConstraintForView(view: progressionsTableView,
                                                                 height: 0)
            progressionsTableView.heightConstraint?.isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: progressionsTableView,
                                                             belowView: progressionsLabel,
                                                             withPadding: viewPadding / 2).isActive = true
            NSLayoutConstraint(item: nameEntryLabel,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: progressionsTableView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: nameEntryLabel,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: progressionsTableView,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0).isActive = true
            
            // MARK: Add progression method button
            addProgressionTrackerButton.translatesAutoresizingMaskIntoConstraints = false
            
            addProgressionTrackerButton.setDefaultProperties()
            addProgressionTrackerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            addProgressionTrackerButton.layer.cornerRadius = 5.0
            addProgressionTrackerButton.setOverlayColor(color: UIColor.niceYellow())
            addProgressionTrackerButton.setOverlayStyle(style: .FADE)
            addProgressionTrackerButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            addProgressionTrackerButton.setTitle("Add Progression Tracker", for: .normal)
            addProgressionTrackerButton.setTitleColor(UIColor.niceBlue(), for: .normal)
            addProgressionTrackerButton.setTitleColor(UIColor.white, for: .highlighted)
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createHeightConstraintForView(view: addProgressionTrackerButton,
                                                             height: 50).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: addProgressionTrackerButton,
                                                             belowView: progressionsTableView,
                                                             withPadding: 0).isActive = true
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
            
            // MARK: Create exercise button
            createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
            
            createExerciseButton.setTitle("Create Exercise", for: .normal)
            createExerciseButton.setDefaultProperties()
            createExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: createExerciseButton,
                                                            width: self.frame.width - 50).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: createExerciseButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below add exercise button
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: createExerciseButton,
                                                             belowView: addProgressionTrackerButton,
                                                             withPadding: viewPadding * 2).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: createExerciseButton,
                                                                            inView: self).isActive = true
            
            prevCellCount = progressionsTableView.getData().count
        }
        // We call else if instead of just doing if so that when we come back to this view
        // Otherwise, contentSize does not get properly updated.
        else if prevCellCount != progressionsTableView.getData().count {
            prevCellCount = progressionsTableView.getData().count
            self.contentSize.height = createExerciseButton.frame.maxY + 50 + viewPadding
        }
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
}

// MARK: Protocol

protocol CreateExerciseViewDelegate {
    // Pass exercise result from this screen to the delegate
    func finishedWithExercise(exercise: Exercise)
}
