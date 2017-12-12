//
//  CreateWorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/11/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class CreateWorkoutView: UIScrollView {
    
    // MARK: View properties
    
    // Padding between views
    let viewPadding: CGFloat = 20.0
    
    // Delegate that does something when workout complete
    public var dataDelegate: CreateWorkoutViewDelegate?
    // Delegate to show a view
    public var showViewDelegate: ShowViewDelegate?
    
    // holds the first char for the days of the week for repeat buttons
    private final let daysOfTheWeekChars = ["S", "M", "T", "W", "T", "F", "S"]
    // variable stating how many cells are in the exercise table view
    private var prevDataCount = -1
    // the exercise the user is editing
    private var editingWorkout: Workout? = nil
    
    // labels this view
    private let createWorkoutLabel: UILabel
    // Field to enter name
    private let nameEntryField: BetterTextField
    // Exercise Table Label
    private let exerciseTableLabel: UILabel
    // Table holding all of our exercises
    private let editExerciseTableView: EditExerciseTableView
    // button to add a new exercise to this view
    private let addExerciseButton: PrettyButton
    // repeat label
    private let repeatLabel: UILabel
    // repeat contents
    private let repeatButtonView: UIView
    // all of the repeat buttons
    private var repeatButtons: [ToggleablePrettyButton]
    // Button to create our workout
    private let createWorkoutButton: PrettyButton
    // Cancel button
    private let cancelButton: PrettyButton
    
    // MARK: View inits
    
    init(workout: Workout? = nil, frame: CGRect) {
        editingWorkout = workout
        
        createWorkoutLabel = UILabel()
        nameEntryField = BetterTextField(defaultString: "Required: Name", frame: .zero)
        exerciseTableLabel = UILabel()
        editExerciseTableView = EditExerciseTableView()
        repeatLabel = UILabel()
        repeatButtonView = UIView()
        repeatButtons = [ToggleablePrettyButton]()
        addExerciseButton = PrettyButton()
        createWorkoutButton = PrettyButton()
        cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(createWorkoutLabel)
        addSubview(nameEntryField)
        addSubview(exerciseTableLabel)
        addSubview(editExerciseTableView)
        addSubview(addExerciseButton)
        addSubview(repeatLabel)
        addSubview(repeatButtonView)
        addSubview(createWorkoutButton)
        addSubview(cancelButton)
        
        createAndActivateCreateWorkoutLabelConstraints()
        createAndActivateNameEntryFieldConstraints()
        createAndActivateExerciseTableLabelConstraints()
        createAndActivateEditExerciseTableViewConstraints()
        createAndActivateAddExerciseButtonConstraints()
        createAndActivateRepeatLabelConstraints()
        createAndActivateRepeatButtonViewConstraints()
        createAndActivateCreateWorkoutButtonConstraints()
        createAndActivateCancelButtonConstraints()
        
        createRepeatButtons(encapsulatingView: repeatButtonView)
        
        addExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        createWorkoutButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        // If we're editing...
        if let workout = editingWorkout {
            nameEntryField.textfield.text = workout.getName()
            
            for exercise in workout.getExercises() {
                editExerciseTableView.appendDataToTableView(data: exercise)
            }
            
            let repeatOnDays = workout.getsDayOfTheWeek()
            for (index, button) in repeatButtons.enumerated() {
                button.setIsToggled(toggled: repeatOnDays[index].value)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self stuff
        backgroundColor = .niceGray
        contentSize.height = cancelButton.frame.maxY + viewPadding
        
        // Label
        createWorkoutLabel.setDefaultProperties()
        createWorkoutLabel.text = editingWorkout != nil ? "Edit Workout" : "Create New Workout"
        
        // Name Entry Field
        nameEntryField.setDefaultProperties()
        nameEntryField.setLabelTitle(title: "Name")
        
        // Repeat Label
        repeatLabel.setDefaultProperties()
        repeatLabel.text = "Repeat"
        
        // Repeat Buton
        for repeatButton in repeatButtons {
            repeatButton.setToggleViewColor(color: .niceYellow)
            repeatButton.setToggleTextColor(color: .white)
            repeatButton.setDefaultTextColor(color: UIColor.black.withAlphaComponent(0.25))
            repeatButton.setDefaultViewColor(color: .white)
            
            repeatButton.layer.cornerRadius = (repeatButton.frame.width / 2)
        }
        
        // Exercise Table Label
        exerciseTableLabel.setDefaultProperties()
        exerciseTableLabel.text = "Exercises"
        
        // Exercise Table View
        // Prevent clipping as we can click and drag cells
        editExerciseTableView.clipsToBounds = false
        editExerciseTableView.isScrollEnabled = false
        editExerciseTableView.backgroundColor = .clear
        
        // Add exercise button
        addExerciseButton.setDefaultProperties()
        addExerciseButton.setTitle("Add exercise", for: .normal)
        
        // Create workout button
        // Give it standard default properties
        createWorkoutButton.setDefaultProperties()
        createWorkoutButton.setTitle(editingWorkout != nil ? "Save Workout" : "Create Workout", for: .normal)
        
        // Cancel Button
        cancelButton.setDefaultProperties()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .niceRed
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: PrettyButton) {
        nameEntryField.textfield.resignFirstResponder()
        
        switch (sender) {
        case addExerciseButton:
            /*
             * We use superview here as this view is a scrollview. This could
             * alternatively be done by having an encasing view for every workoutview.
             * That may be considered best practice... So, TODO
             */
            let exercisePickerView = ExercisesView(selectingExercise: true,
                                                   frame: .zero)
            exercisePickerView.exercisePickerDelegate = self
            
            guard let showViewDelegate = showViewDelegate else {
                fatalError("ShowViewDelegate not set for ExercisePicker")
            }
            showViewDelegate.showView(exercisePickerView)
            
        case createWorkoutButton:
            if checkRequirementsFulfilled() {
                // Send info to delegate, animate up then remove self
                let savedWorkout = saveAndReturnWorkout()
                
                // Prevent user interaction with all subviews
                for subview in subviews {
                    subview.isUserInteractionEnabled = false
                }
                
                // Slide up, then remove from view
                UIView.animate(withDuration: 0.2, animations: {
                    self.frame = CGRect(x: 0,
                                   y: -self.frame.height,
                                   width: self.frame.width,
                                   height: self.frame.height)
                }, completion: {
                    (finished:Bool) -> Void in
                    self.dataDelegate?.finishedWithWorkout(workout: savedWorkout)
                    self.removeFromSuperview()
                })
            }
            break
        case cancelButton:
            removeSelfNicelyWithAnimation()
            break
        default:
            fatalError("Button pressed was not assigned function")
        }
    }
    
    // MARK: Private functions
    
    // Check if requirements per workout are completed
    private func checkRequirementsFulfilled() -> Bool {
        var fulfilled = true
        
        if nameEntryField.textfield.text?.count == 0 {
            nameEntryField.textfield.backgroundColor = .niceRed
            
            fulfilled = false
        }
        
        return fulfilled
    }
    
    // Use data on this form to create the workout
    private func saveAndReturnWorkout() -> Workout {
        let savedWorkout = editingWorkout ?? Workout()
        
        savedWorkout.setName(name: nameEntryField.text)
        savedWorkout.setDaysOfTheWeek(daysOfTheWeek: getDaysOfTheWeek())
        
        savedWorkout.removeExercies()
        for exercise in editExerciseTableView.getData() {
            savedWorkout.addExercise(exercise: exercise)
        }
        
        // If this is a new workout, save it.
        if editingWorkout == nil {
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(savedWorkout)
            }
        }
        
        // Return this workout
        return savedWorkout
    }
    
    // Creates the repeat buttons
    private func createRepeatButtons(encapsulatingView: UIView) {
        var prevView = encapsulatingView
        
        for dayChar in daysOfTheWeekChars {
            let dayButton = ToggleablePrettyButton()
            dayButton.setTitle(dayChar, for: .normal)
            
            addSubview(dayButton)
            repeatButtons.append(dayButton)
            
            // MARK: dayButton constraints
            
            dayButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == encapsulatingView ? .left : .right,
                               relatedBy: .equal,
                               toItem: dayButton,
                               attribute: .left,
                               multiplier: 1,
                               constant: prevView == encapsulatingView ? -2.5 : -5).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dayButton,
                                                                 withCopyView: encapsulatingView,
                                                                 attribute: .top).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dayButton,
                                                                 withCopyView: encapsulatingView,
                                                                 attribute: .width,
                                                                 multiplier: 1/CGFloat(daysOfTheWeekChars.count),
                                                                 plusConstant: -5 * CGFloat(daysOfTheWeekChars.count)
                ).isActive = true
            // Constraint makes sure these buttons are circles
            NSLayoutConstraint(item: dayButton,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: dayButton,
                               attribute: .width,
                               multiplier: 1,
                               constant: 0).isActive = true
            
            
            // reset prevView to this view for constraints
            prevView = dayButton
        }
    }
    
    private func getDaysOfTheWeek() -> List<RLMBool> {
        let toggledIndices = List<RLMBool>()
        
        for button in repeatButtons {
            let rlmBool = RLMBool()
            rlmBool.value = button.isToggled
            toggledIndices.append(rlmBool)
        }
        
        return toggledIndices
    }
    
    // MARK: Constraints
    
    // center horiz in view; cling to top; width of this view ; height 30
    private func createAndActivateCreateWorkoutLabelConstraints() {
        createWorkoutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: viewPadding).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createWorkoutLabel,
                                                         height: 30).isActive = true
    }
    
    // Center horiz in view; place below self ; height of default height ; width of this view - 40
    private func createAndActivateNameEntryFieldConstraints() {
        // Name entry field
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                         belowView: createWorkoutLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                         height: BetterTextField.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -40).isActive = true
        
    }
    
    // Center horiz in view ; place below nameEntryField ; height of 20 ; width of this view - 80
    private func createAndActivateExerciseTableLabelConstraints() {
        exerciseTableLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: exerciseTableLabel,
                                                         belowView: nameEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: exerciseTableLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // Center horiz in view ; place below exerciseTableLabel ; Default height of 0 ; Width of this view - 40
    private func createAndActivateEditExerciseTableViewConstraints() {
        editExerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editExerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: editExerciseTableView,
                                                         belowView: exerciseTableLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        
        // Height constraint property assigning; increases based on number of cells
        editExerciseTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: editExerciseTableView, height: 0)
        editExerciseTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editExerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // place below exercisetableview ; left/right match to exercisetableview ; height of default height
    private func createAndActivateAddExerciseButtonConstraints() {
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: addExerciseButton,
                                                         belowView: editExerciseTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addExerciseButton,
                                                             withCopyView: editExerciseTableView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addExerciseButton,
                                                             withCopyView: editExerciseTableView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatLabelConstraints() {
        repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: repeatLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: repeatLabel,
                                                         belowView: addExerciseButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: repeatLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: repeatLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatButtonViewConstraints() {
        repeatButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: repeatButtonView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: repeatButtonView,
                                                         belowView: repeatLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint(item: repeatButtonView,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: repeatButtonView,
                           attribute: .height,
                           multiplier: CGFloat(daysOfTheWeekChars.count),
                           constant: 5 * CGFloat(daysOfTheWeekChars.count)).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: repeatButtonView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // center horiz in view ; place below add exercise button ; height of default ; width of this view - 50
    private func createAndActivateCreateWorkoutButtonConstraints() {
        createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: createWorkoutButton,
                                                         belowView: repeatButtonView,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: createWorkoutButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: createWorkoutButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // center horiz in view ; place below createWorkoutButton; height 30 ; width of createWorkoutButton - 40
    private func createAndActivateCancelButtonConstraints() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: cancelButton,
                                                         belowView: createWorkoutButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cancelButton,
                                                             withCopyView: createWorkoutButton,
                                                             attribute: .width,
                                                             plusConstant: 0).isActive = true
    }
}

extension CreateWorkoutView: ExercisePickerDelegate {
    // whenever an exercise is selected from our select exercise view
    func didSelectExercise(exercise: Exercise) {
        editExerciseTableView.appendDataToTableView(data: exercise)
    }
}

protocol CreateWorkoutViewDelegate {
    func finishedWithWorkout(workout: Workout)
}
