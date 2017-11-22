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

class CreateWorkoutView: UIScrollView, ExercisePickerDelegate, ShowViewDelegate {
    
    // MARK: View properties
    
    // Padding between views
    let viewPadding: CGFloat = 20.0
    
    // Delegate that does something when workout complete
    public var dataDelegate: CreateWorkoutViewDelegate?
    
    // holds the first char for the days of the week for repeat buttons
    private final let daysOfTheWeekChars = ["S", "M", "T", "W", "T", "F", "S"]
    // variable stating how many cells are in the exercise table view
    private var prevDataCount = -1
    // the exercise the user is editing
    private var editingWorkout: Workout? = nil
    
    // labels this view
    private var createWorkoutLabel: UILabel
    // Field to enter name
    private var nameEntryField: BetterTextField
    // Exercise Table Label
    private var exerciseTableLabel: UILabel
    // Table holding all of our exercises
    private var editExerciseTableView: EditExerciseTableView
    // button to add a new exercise to this view
    private var addExerciseButton: PrettyButton
    // repeat label
    private var repeatLabel: UILabel
    // repeat contents
    private var repeatButtonView: UIView
        // all of the repeat buttons
        private var repeatButtons: [ToggleablePrettyButton]
    // Button to create our workout
    private var createWorkoutButton: PrettyButton
    // Cancel button
    private var cancelButton: PrettyButton
    
    init(workout: Workout? = nil, frame: CGRect) {
        self.editingWorkout = workout
        
        self.createWorkoutLabel = UILabel()
        self.nameEntryField = BetterTextField(defaultString: "Required: Name", frame: .zero)
        self.exerciseTableLabel = UILabel()
        self.editExerciseTableView = EditExerciseTableView()
        self.repeatLabel = UILabel()
        self.repeatButtonView = UIView()
            self.repeatButtons = [ToggleablePrettyButton]()
        self.addExerciseButton = PrettyButton()
        self.createWorkoutButton = PrettyButton()
        self.cancelButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(self.createWorkoutLabel)
        self.addSubview(self.nameEntryField)
        self.addSubview(self.exerciseTableLabel)
        self.addSubview(self.editExerciseTableView)
        self.addSubview(self.addExerciseButton)
        self.addSubview(self.repeatLabel)
        self.addSubview(self.repeatButtonView)
        self.addSubview(self.createWorkoutButton)
        self.addSubview(self.cancelButton)
        
        self.createAndActivateCreateWorkoutLabelConstraints()
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivateExerciseTableLabelConstraints()
        self.createAndActivateEditExerciseTableViewConstraints()
        self.createAndActivateAddExerciseButtonConstraints()
        self.createAndActivateRepeatLabelConstraints()
        self.createAndActivateRepeatButtonViewConstraints()
        self.createAndActivateCreateWorkoutButtonConstraints()
        self.createAndActivateCancelButtonConstraints()
        
        self.createRepeatButtons(encapsulatingView: repeatButtonView)
        
        self.addExerciseButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.createWorkoutButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        // If we're editing...
        if let workout = self.editingWorkout {
            self.nameEntryField.textfield.text = workout.getName()!
            
            for exercise in workout.getExercises() {
                self.editExerciseTableView.appendDataToTableView(data: exercise)
            }
            
            let repeatOnDays = workout.getsDayOfTheWeek()
            for (index, button) in self.repeatButtons.enumerated() {
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
        self.backgroundColor = UIColor.niceGray
        self.contentSize.height = cancelButton.frame.maxY + viewPadding
        
        // Label
        self.createWorkoutLabel.setDefaultProperties()
        self.createWorkoutLabel.text = self.editingWorkout != nil ? "Edit Workout" : "Create New Workout"
        
        // Name Entry Field
        self.nameEntryField.setDefaultProperties()
        self.nameEntryField.setLabelTitle(title: "Name")
        
        // Repeat Label
        self.repeatLabel.setDefaultProperties()
        self.repeatLabel.text = "Repeat"
        
        // Repeat Buton
        for repeatButton in self.repeatButtons {
            repeatButton.setToggleViewColor(color: UIColor.niceYellow)
            repeatButton.setToggleTextColor(color: .white)
            repeatButton.setDefaultTextColor(color: UIColor.black.withAlphaComponent(0.25))
            repeatButton.setDefaultViewColor(color: .white)
            
            repeatButton.layer.cornerRadius = (repeatButton.frame.width / 2)
        }
        
        // Exercise Table Label
        self.exerciseTableLabel.setDefaultProperties()
        self.exerciseTableLabel.text = "Exercises (Hold + Drag to Reorder)"
        
        // Exercise Table View
        // Prevent clipping as we can click and drag cells
        self.editExerciseTableView.clipsToBounds = false
        self.editExerciseTableView.isScrollEnabled = false
        self.editExerciseTableView.backgroundColor = UIColor.clear
        
        // Add exercise button
        self.addExerciseButton.setDefaultProperties()
        self.addExerciseButton.setTitle("Add exercise", for: .normal)
        
        // Create workout button
        // Give it standard default properties
        self.createWorkoutButton.setDefaultProperties()
        self.createWorkoutButton.setTitle(self.editingWorkout != nil ? "Save Workout" : "Create Workout", for: .normal)
        
        // Cancel Button
        self.cancelButton.setDefaultProperties()
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.backgroundColor = UIColor.niceRed
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: PrettyButton) {
        self.nameEntryField.textfield.resignFirstResponder()
        
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
            self.showView(view: exercisePickerView)
            
        case createWorkoutButton:
            if checkRequirementsFulfilled() {
                // Send info to delegate, animate up then remove self
                let savedWorkout = self.saveAndReturnWorkout()
                
                // Prevent user interaction with all subviews
                for subview in self.subviews {
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
            self.removeSelfNicelyWithAnimation()
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
            nameEntryField.textfield.backgroundColor = UIColor.niceRed
            
            fulfilled = false
        }
        
        return fulfilled
    }
    
    // Use data on this form to create the workout
    private func saveAndReturnWorkout() -> Workout {
        let savedWorkout = self.editingWorkout ?? Workout()

        savedWorkout.setName(name: nameEntryField.text)
        savedWorkout.setDaysOfTheWeek(daysOfTheWeek: self.getDaysOfTheWeek())
        
        savedWorkout.removeExercies()
        for exercise in editExerciseTableView.getData() {
            savedWorkout.addExercise(exercise: exercise)
        }
        
        // If this is a new workout, save it.
        if self.editingWorkout == nil {
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
            
            self.addSubview(dayButton)
            self.repeatButtons.append(dayButton)
            
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
                                                                 multiplier: 1/CGFloat(self.daysOfTheWeekChars.count),
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
    
    // MARK: ExercisePickerDelegate Methods
    
    // whenever an exercise is selected from our select exercise view
    func didSelectExercise(exercise: Exercise) {
        self.editExerciseTableView.appendDataToTableView(data: exercise)
    }
    
    // MARK: ShowViewDelegate
    
    func showView(view: UIView) {
        self.superview!.addSubview(view)
        
        view.frame = CGRect(x: 0,
                            y: -self.superview!.frame.height,
                            width: self.superview!.frame.width,
                            height: self.superview!.frame.height)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.frame = CGRect(x: 0,
                                y: 0,
                                width: self.superview!.frame.width,
                                height: self.superview!.frame.height)
        })
    }
    
    // MARK: Constraints
    
    // center horiz in view; cling to top; width of this view ; height 30
    private func createAndActivateCreateWorkoutLabelConstraints() {
        self.createWorkoutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: viewPadding).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createWorkoutLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createWorkoutLabel,
                                                         height: 30).isActive = true
    }
    
    // Center horiz in view; place below self ; height of default height ; width of this view - 40
    private func createAndActivateNameEntryFieldConstraints() {
        // Name entry field
        self.nameEntryField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.nameEntryField,
                                                            belowView: self.createWorkoutLabel,
                                                            withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.nameEntryField,
                                                         height: BetterTextField.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                            withCopyView: self,
                                                            attribute: .width,
                                                            plusConstant: -40).isActive = true

    }
    
    // Center horiz in view ; place below nameEntryField ; height of 20 ; width of this view - 80
    private func createAndActivateExerciseTableLabelConstraints() {
        self.exerciseTableLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseTableLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.exerciseTableLabel,
                                                         belowView: self.nameEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.exerciseTableLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseTableLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // Center horiz in view ; place below exerciseTableLabel ; Default height of 0 ; Width of this view - 40
    private func createAndActivateEditExerciseTableViewConstraints() {
        self.editExerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editExerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.editExerciseTableView,
                                                         belowView: self.exerciseTableLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        
        // Height constraint property assigning; increases based on number of cells
        self.editExerciseTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: self.editExerciseTableView, height: 0)
        self.editExerciseTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.editExerciseTableView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // place below exercisetableview ; left/right match to exercisetableview ; height of default height
    private func createAndActivateAddExerciseButtonConstraints() {
        self.addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
 
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.addExerciseButton,
                                                         belowView: self.editExerciseTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addExerciseButton,
                                                             withCopyView: self.editExerciseTableView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addExerciseButton,
                                                             withCopyView: self.editExerciseTableView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addExerciseButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatLabelConstraints() {
        self.repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.repeatLabel,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.repeatLabel,
                                                         belowView: self.addExerciseButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.repeatLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.repeatLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatButtonViewConstraints() {
        self.repeatButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.repeatButtonView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.repeatButtonView,
                                                         belowView: self.repeatLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint(item: self.repeatButtonView,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.repeatButtonView,
                           attribute: .height,
                           multiplier: CGFloat(self.daysOfTheWeekChars.count),
                           constant: 5 * CGFloat(self.daysOfTheWeekChars.count)).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.repeatButtonView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -20).isActive = true
    }
    
    // center horiz in view ; place below add exercise button ; height of default ; width of this view - 50
    private func createAndActivateCreateWorkoutButtonConstraints() {
        self.createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createWorkoutButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.createWorkoutButton,
                                                         belowView: self.repeatButtonView,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createWorkoutButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.createWorkoutButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             plusConstant: -50).isActive = true
    }
    
    // center horiz in view ; place below createWorkoutButton; height 30 ; width of createWorkoutButton - 40
    private func createAndActivateCancelButtonConstraints() {
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.cancelButton,
                                                         belowView: self.createWorkoutButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cancelButton,
                                                             withCopyView: self.createWorkoutButton,
                                                             attribute: .width,
                                                             plusConstant: 0).isActive = true
    }
}

protocol CreateWorkoutViewDelegate {
    func finishedWithWorkout(workout: Workout)
}
