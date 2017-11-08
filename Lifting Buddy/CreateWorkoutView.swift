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

class CreateWorkoutView: UIScrollView, ExercisePickerDelegate {
    
    // View properties
    
    // Padding between views
    let viewPadding: CGFloat = 20.0
    
    // Delegate that does something when workout complete
    public var dataDelegate: CreateWorkoutViewDelegate?
    
    // variable stating how many cells are in the exercise table view
    private var prevDataCount = -1
    // holds the first char for the days of the week for repeat buttons
    private final let daysOfTheWeekChars = ["S", "M", "T", "W", "T", "F", "S"]
    
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
    
    override init(frame: CGRect) {
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self stuff
        self.backgroundColor = UIColor.niceGray()
        self.contentSize.height = cancelButton.frame.maxY + viewPadding
        
        // Label
        self.createWorkoutLabel.setDefaultProperties()
        self.createWorkoutLabel.text = "Create New Workout"
        
        // Name Entry Field
        self.nameEntryField.setDefaultProperties()
        self.nameEntryField.setLabelTitle(title: "Name")
        
        // Repeat Label
        self.repeatLabel.setDefaultProperties()
        self.repeatLabel.text = "Repeat"
        
        // Repeat Buton
        for repeatButton in self.repeatButtons {
            repeatButton.setToggleViewColor(color: .niceYellow())
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
        self.addExerciseButton.setTitle("Add exercise", for: .normal)
        self.addExerciseButton.setTitleColor(UIColor.niceBlue(), for: .normal)
        self.addExerciseButton.setTitleColor(UIColor.white, for: .highlighted)
        self.addExerciseButton.setDefaultProperties()
        self.addExerciseButton.setOverlayStyle(style: .FADE)
        self.addExerciseButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.addExerciseButton.setOverlayColor(color: UIColor.niceYellow())
        // Event press for exercise button
        self.addExerciseButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        
        // Create workout button
        // Give it standard default properties
        self.createWorkoutButton.setDefaultProperties()
        self.createWorkoutButton.setTitle("Create Workout", for: .normal)
        self.createWorkoutButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        // Cancel Button
        self.cancelButton.setDefaultProperties()
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        self.cancelButton.backgroundColor = UIColor.niceRed()
    }
    
    // MARK: Event functions
    
    @objc func buttonPressed(sender: PrettyButton) {
        nameEntryField.resignFirstResponder()
        
        switch (sender) {
        case addExerciseButton:
            /*
             * We use superview here as this view is a scrollview. This could
             * alternatively be done by having an encasing view for every workoutview.
             * That may be considered best practice... So, TODO
             */
            let exercisePickerView = ExercisesView(selectingExercise: true,
                                                   frame: CGRect(x: 0,
                                                                 y: -self.superview!.frame.height,
                                                                 width: self.superview!.frame.width,
                                                                 height: self.superview!.frame.height))
            exercisePickerView.exercisePickerDelegate = self
            self.superview!.addSubview(exercisePickerView)
            
            UIView.animate(withDuration: 0.5, animations: {
                exercisePickerView.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: self.superview!.frame.width,
                                                  height: self.superview!.frame.height)
            })
            break
        case createWorkoutButton:
            if checkRequirementsFulfilled() {
                // Send info to delegate, animate up then remove self
                let createdWorkout = createWorkoutWithData()
                
                let realm = try! Realm()
                try! realm.write {
                    realm.add(createdWorkout)
                }
                
                // Prevent user interaction with all subviews
                for subview in self.subviews {
                    subview.isUserInteractionEnabled = false
                }
                
                // Slide up, then remove from view
                UIView.animate(withDuration: 0.5, animations: {
                    self.frame = CGRect(x: 0,
                                        y: -self.frame.height,
                                        width: self.frame.width,
                                        height: self.frame.height)
                }, completion: {
                    (finished:Bool) -> Void in
                    self.dataDelegate?.finishedWithWorkout(workout: createdWorkout)
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
            nameEntryField.textfield.backgroundColor = UIColor.niceRed()
            
            fulfilled = false
        }
        
        return fulfilled
    }
    
    // Use data on this form to create the workout
    private func createWorkoutWithData() -> Workout {
        let createdWorkout = Workout()
        
        createdWorkout.setName(name: nameEntryField.text)
        createdWorkout.setDaysOfTheWeek(daysOfTheWeek: self.getDaysOfTheWeek())
        
        for exercise in editExerciseTableView.getData() {
            createdWorkout.addExercise(exercise: exercise)
        }
        
        return createdWorkout
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
            NSLayoutConstraint.createViewBelowViewTopConstraint(view: dayButton,
                                                                belowView: encapsulatingView,
                                                                withPadding: 0).isActive = true
            NSLayoutConstraint(item: encapsulatingView,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: dayButton,
                               attribute: .width,
                               multiplier: CGFloat(daysOfTheWeekChars.count),
                               constant: 5 * CGFloat(daysOfTheWeekChars.count)).isActive = true
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
    
    // MARK: Constraints
    
    // center horiz in view; cling to top; width of this view ; height 30
    private func createAndActivateCreateWorkoutLabelConstraints() {
        self.createWorkoutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.createWorkoutLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: self.createWorkoutLabel,
                                                            belowView: self,
                                                            withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.createWorkoutLabel,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createWorkoutLabel,
                                                         height: 30).isActive = true
    }
    
    // Center horiz in view; place below self ; height of 50 ; width of this view - 40
    private func createAndActivateNameEntryFieldConstraints() {
        // Name entry field
        self.nameEntryField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.nameEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.nameEntryField,
                                                            belowView: self.createWorkoutLabel,
                                                            withPadding: viewPadding / 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.nameEntryField,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.nameEntryField,
                                                            withCopyView: self,
                                                            plusWidth: -40).isActive = true

    }
    
    // Center horiz in view ; place below nameEntryField ; height of 20 ; width of this view - 80
    private func createAndActivateExerciseTableLabelConstraints() {
        self.exerciseTableLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.exerciseTableLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.exerciseTableLabel,
                                                         belowView: self.nameEntryField,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.exerciseTableLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: exerciseTableLabel,
                                                            withCopyView: self,
                                                            plusWidth: -80).isActive = true
    }
    
    // Center horiz in view ; place below exerciseTableLabel ; Default height of 0 ; Width of this view - 40
    private func createAndActivateEditExerciseTableViewConstraints() {
        self.editExerciseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.editExerciseTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.editExerciseTableView,
                                                         belowView: self.exerciseTableLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        
        // Height constraint property assigning; increases based on number of cells
        self.editExerciseTableView.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: editExerciseTableView, height: 0)
        self.editExerciseTableView.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.editExerciseTableView,
                                                            withCopyView: self,
                                                            plusWidth: -50).isActive = true
    }
    
    // place below exercisetableview ; left/right match to exercisetableview ; height 50
    private func createAndActivateAddExerciseButtonConstraints() {
        self.addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
 
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.addExerciseButton,
                                                         belowView: self.editExerciseTableView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: self.editExerciseTableView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.addExerciseButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self.editExerciseTableView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.addExerciseButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addExerciseButton,
                                                         height: 50).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatLabelConstraints() {
        self.repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.repeatLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.repeatLabel,
                                                         belowView: self.addExerciseButton,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.repeatLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.repeatLabel,
                                                            withCopyView: self,
                                                            plusWidth: -20).isActive = true
    }
    
    // center horiz in view ; place below name entry field ; height 20 ; width of this view - 20
    private func createAndActivateRepeatButtonViewConstraints() {
        self.repeatButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.repeatButtonView,
                                                                        inView: self).isActive = true
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
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.repeatButtonView,
                                                            withCopyView: self,
                                                            plusWidth: -20).isActive = true
    }
    
    // center horiz in view ; place below add exercise button ; height of 50 ; width of this view - 50
    private func createAndActivateCreateWorkoutButtonConstraints() {
        self.createWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.createWorkoutButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.createWorkoutButton,
                                                         belowView: self.repeatButtonView,
                                                         withPadding: viewPadding * 2).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.createWorkoutButton,
                                                         height: 50).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.createWorkoutButton,
                                                            withCopyView: self,
                                                            plusWidth: -50).isActive = true
    }
    
    // center horiz in view ; place below createWorkoutButton; height 30 ; width of createWorkoutButton - 40
    private func createAndActivateCancelButtonConstraints() {
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.cancelButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.cancelButton,
                                                         belowView: self.createWorkoutButton,
                                                         withPadding: viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.cancelButton,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: self.cancelButton,
                                                            withCopyView: self.createWorkoutButton,
                                                            plusWidth: 0).isActive = true
    }
}

protocol CreateWorkoutViewDelegate {
    func finishedWithWorkout(workout: Workout)
}
