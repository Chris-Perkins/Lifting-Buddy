//
//  CreateExerciseView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
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
            
            progressionsTableView = ProgressionsTableView(frame: CGRect(x: 10,
                                                                        y: viewPadding * 5 + 160,
                                                                        width: self.frame.width - 20,
                                                                        height: 0),
                                                                        style: .plain)
            // Prevent clipping as we can click and drag cells
            progressionsTableView.clipsToBounds = false
            progressionsTableView.isScrollEnabled = false
            progressionsTableView.backgroundColor = UIColor.clear
            progressionsTableView.appendDataToTableView(data: ProgressionMethod())
            
            self.addSubview(progressionsTableView)
            
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
            NSLayoutConstraint.createWidthConstraintForView(view: addProgressionTrackerButton,
                                                            width: progressionsTableView.frame.width).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: addProgressionTrackerButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below exerciseTableView
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: addProgressionTrackerButton,
                                                             belowView: progressionsTableView,
                                                             withPadding: 0).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: addProgressionTrackerButton,
                                                                            inView: self).isActive = true
            
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
                self.dataDelegate?.finishedWithExercise(exercise: Exercise())
                UIView.animate(withDuration: 0.5, animations: {
                    self.frame = CGRect(x: 0,
                                        y: -self.frame.height,
                                        width: self.frame.width,
                                        height: self.frame.height)
                }, completion: {
                    (finished:Bool) -> Void in
                    self.removeFromSuperview()
                })
            }
            break
        default:
            fatalError("User pressed a button that does not exist in switch?")
        }
    }
    
    // MARK: Private functions
    
    private func requirementsFulfilled() -> Bool {
        var fulfilled: Bool = true
        
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
        
        return fulfilled
    }
}

// MARK: Protocol

protocol CreateExerciseViewDelegate {
    func finishedWithExercise(exercise: Exercise)
}
