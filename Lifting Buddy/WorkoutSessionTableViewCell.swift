//
//  WorkoutSessionTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutSessionTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // Padding between views
    private let viewPadding: CGFloat = 15.0
    // Table view height for expansion
    private let tableViewHeight: CGFloat = 150.0
    
    // Title bar properties
    
    // the button we press to toggle this cell. It's invisible (basically)
    private let invisButton: PrettyButton
    // the title of this cell, holds the title of the exercise name
    private let cellTitle: UILabel
    // An image that shows whether or not this cell is expanded
    private let expandImage: UIImageView
    // Cell contents on expand
    private let setLabel: UILabel
    // view where we put the input textfields
    private let inputContentView: UIView
    // add a set to the table
    private let addSetButton: PrettyButton
    // table view that holds the history of our exercise this go around
    private let exerciseHistoryTableView: ExerciseHistoryTableView
    
    // the fields themselves in the inputcontent view
    private var exerciseInputFields: [InputViewHolder]
    // Exercise assigned to this cell
    private var exercise: Exercise
    // Whether or not this exercise is complete
    private var isComplete: Bool
    // Holds whether this view is toggled
    private var isToggled: Bool
    // Data we're displaying
    private var data: [[Float]]
    // The current set we're doing
    private var curSet: Int
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: WorkoutSessionTableViewCellDelegate?
    public var deletionDelegate: CellDeletionDelegate?
    
    // MARK: Init Functions
    
    init(exercise: Exercise, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.exercise = exercise
        
        invisButton = PrettyButton()
        cellTitle = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        
        setLabel = UILabel()
        inputContentView = UIView()
        exerciseInputFields = [InputViewHolder]()
        addSetButton = PrettyButton()
        exerciseHistoryTableView = ExerciseHistoryTableView(forExercise: exercise,
                                                            style: .plain)
        
        data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        curSet = 1
        isComplete = false
        isToggled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(invisButton)
        addSubview(cellTitle)
        addSubview(expandImage)
        addSubview(inputContentView)
        addSubview(addSetButton)
        addSubview(exerciseHistoryTableView)
        
        createAndActivateInvisButtonConstraints()
        createAndActivateCellTitleConstraints()
        createAndActivateExpandImageConstraints()
        createAndActivateInputContentViewConstraints()
        createAndActivateInputFieldsConstraints()
        createAndActivateAddSetButtonConstraints()
        createAndActivateExerciseHistoryTableViewConstraints()
        
        giveInvisButtonProperties()
        
        exerciseHistoryTableView.tableViewDelegate = self
        addSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Checks if it's safe to use exercise. Otherwise, delete this cell
        if exercise.isInvalidated {
            self.deletionDelegate?.deleteData(at: indexPath!.row)
        }
        
        // Self stuff
        
        updateCompleteStatus()
        selectionStyle = .none
        clipsToBounds = true
        
        
        // Cell Title
        let curSetCount: Int = exerciseHistoryTableView.getData().count
        let reqSetCount: Int = exercise.getSetCount()
        /* Text depends on whether or not we have a required set amount.
         * If we do, a format example is [1/2]
         * If we don't, the same example is [1]
         */
        cellTitle.text = reqSetCount > 0 ?
            "[\(curSetCount)/\(reqSetCount)] \(exercise.getName()!)":
        "[\(curSetCount)] \(exercise.getName()!)"
        cellTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        // Invisible Button has to be "visible" to be pressed. So, 0.001
        invisButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        
        // Add Set button
        addSetButton.setDefaultProperties()
        addSetButton.setTitle("Add Set", for: .normal)
        
        // Different states for whether the cell is complete or not.
        // If complete: cell turns green, title color turns white to be visible.
        // If not complete: Cell is white
        if isComplete {
            backgroundColor = UIColor.niceGreen.withAlphaComponent(isToggled ? 0.85 : 0.75)
            cellTitle.textColor = .white
        } else {
            backgroundColor = isToggled ? .lightestBlackWhiteColor : .primaryBlackWhiteColor
            cellTitle.textColor = .niceBlue
        }
    }
    
    // MARK: View functions
    
    // Sets the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
    }
    
    // Changes whether or not this cell is toggled
    public func updateToggledStatus() {
        if indexPath != nil {
            delegate?.cellHeightDidChange(height: getHeight(),
                                          indexPath: indexPath!)
            expandImage.transform = CGAffineTransform(scaleX: 1,
                                                      y: isToggled ? -1 : 1)
        }
    }
    
    // Gets the height of the current cell
    private func getHeight() -> CGFloat {
        return isToggled ? getExpandedHeight() : UITableViewCell.defaultHeight
    }
    
    // gets the height of this cell when expanded
    private func getExpandedHeight() -> CGFloat {
        // total padding for this view. Incremement by one per each "cell" of this view
        var totalPadding = 0
        
        let titleBarHeight = UITableViewCell.defaultHeight
        let contentHeight = getContentHeight()
        
        let addSetButtonHeight = PrettyButton.defaultHeight
        totalPadding += 1
        
        let totalTableViewHeight = tableViewHeight + viewPadding
        totalPadding += 1
        
        // Swift compiler doesn't like if we do too much addition at once. :-)
        let heightTop = titleBarHeight + contentHeight + addSetButtonHeight
        let heightBottom = totalTableViewHeight
        
        return heightTop + heightBottom + CGFloat(totalPadding) * viewPadding
    }
    
    // gets the height of the content view
    private func getContentHeight() -> CGFloat {
        return viewPadding * 2 + CGFloat(exercise.getProgressionMethods().count) * 40.0
    }
    
    // saves workout data
    // Returns true if successful
    private func saveWorkoutDataIfPossible() {
        var canAddSet = true
        for inputField in exerciseInputFields {
            // Cannot just return here ; all fields will be marked red.
            // Not all fields are marked red if we return immediately.
            if !(inputField.areFieldsValid()) {
                canAddSet = false
            }
        }
        
        if canAddSet {
            // Add the set to our exerciseHistory. But first, create it.
            let progressionMethods = exercise.getProgressionMethods()
            let exerciseEntry = ExerciseHistoryEntry()
            exerciseEntry.date = Date(timeIntervalSinceNow: 0)
            exerciseEntry.exerciseInfo = List<RLMExercisePiece>()
            
            // For every progressionMethod, set the associated value
            // TODO: Convert the input views to a tableview to make this less spaghetti.
            for (index, exerciseInputField) in exerciseInputFields.enumerated() {
                let exercisePiece = RLMExercisePiece()
                exercisePiece.progressionMethod = progressionMethods[index]
                exercisePiece.value = exerciseInputField.getValue()
                
                exerciseEntry.exerciseInfo.append(exercisePiece)
                
                // Set the progressionmethod default value to whatever was entered.
                // This allows the user to see what value they entered the next time they do their workout.
                progressionMethods[index].setDefaultValue(defaultValue: exerciseInputField.getValue())
                exerciseInputField.setDefaultValue(exerciseInputField.getValue())
                exerciseInputField.clearFields()
            }
            
            exercise.appendExerciseHistoryEntry(exerciseEntry)
            
            exerciseHistoryTableView.appendDataToTableView(data: exerciseEntry)
        }
    }
    
    // Update the complete status (call when some value changed)
    public func updateCompleteStatus() {
        let newComplete = exerciseHistoryTableView.getData().count >= exercise.getSetCount()
        
        // We updated our completed status! So inform the delegate.
        if newComplete != isComplete {
            isComplete = newComplete
            delegate?.cellCompleteStatusChanged(complete: isComplete)
            layoutIfNeeded()
        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case invisButton:
            isToggled = !isToggled
            updateToggledStatus()
        case addSetButton:
            saveWorkoutDataIfPossible()
            exerciseHistoryTableView.layoutIfNeeded()
            exerciseHistoryTableView.reloadData()
            updateCompleteStatus()
            layoutIfNeeded()
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set whether or not this cell is toggled
    public func setIsToggled(toggled: Bool) {
        isToggled = toggled
        updateToggledStatus()
    }
    
    // Returns whether or not this exercise is complete (did all sets)
    public func getIsComplete() -> Bool {
        return isComplete
    }
    
    // MARK: Constraints
    
    // Cling to top, left, right ; height of baseviewcell
    private func createAndActivateInvisButtonConstraints() {
        invisButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: invisButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: invisButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: invisButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: invisButton,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Place below view top, cling to left, right ; height of default height
    private func createAndActivateCellTitleConstraints() {
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Cling to top, right ;  height 8.46 ; width 16
    private func createAndActivateExpandImageConstraints() {
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage,
                                                        width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage,
                                                         height: 8.46).isActive = true
    }
    
    private func createAndActivateInputContentViewConstraints() {
        inputContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 25).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: inputContentView,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -25).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: inputContentView,
                                                         belowView: invisButton).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: inputContentView,
                                                         height: getContentHeight()).isActive = true
    }
    
    // create the input fields in the center field
    private func createAndActivateInputFieldsConstraints() {
        var prevView = inputContentView
        
        for progressionMethod in exercise.getProgressionMethods() {
            if progressionMethod.getUnit() != ProgressionMethod.Unit.TIME.rawValue {
                let progressionInput = BetterInputView(args: [(
                    progressionMethod.getName(),
                    progressionMethod.getDefaultValue() ?? progressionMethod.getName(),
                    true
                    )], frame: .zero)
                
                inputContentView.addSubview(progressionInput)
                exerciseInputFields.append(progressionInput)
                
                addConstraintsToInputView(view: progressionInput, prevView: prevView)
                
                prevView = progressionInput
            } else {
                let progressionInput = TimeInputField(frame: .zero)
                
                progressionInput.setDefaultValue(progressionMethod.getDefaultValue())
                
                inputContentView.addSubview(progressionInput)
                exerciseInputFields.append(progressionInput)
                
                addConstraintsToInputView(view: progressionInput, prevView: prevView)
                
                
                prevView = progressionInput
            }
        }
    }
    
    // Add the constraints to the input we just created
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
                           constant: prevView == inputContentView ? -viewPadding : 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: view,
                                                         height: 40).isActive = true
    }
    
    // Place below the input content view
    private func createAndActivateAddSetButtonConstraints() {
        addSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addSetButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addSetButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.75).isActive = true
        NSLayoutConstraint(item: inputContentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: addSetButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addSetButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // center horiz in view ; width of this view/1.33 ; place below add set button ; height of tableviewheight
    private func createAndActivateExerciseHistoryTableViewConstraints() {
        exerciseHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseHistoryTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exerciseHistoryTableView,
                                                             withCopyView: addSetButton,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint(item: addSetButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: exerciseHistoryTableView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: exerciseHistoryTableView,
                                                         height: tableViewHeight).isActive = true
    }
    
    // MARK: view properties assigned
    
    // Gives the invisible button the properties it needs to function
    private func giveInvisButtonProperties() {
        invisButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
}

extension WorkoutSessionTableViewCell: ExerciseHistoryEntryTableViewDelegate {
    // Called when a cell is deleted
    func dataDeleted(deletedData: ExerciseHistoryEntry) {
        let realm = try! Realm()
        print(realm.objects(ExerciseHistoryEntry.self))
        
        exercise.removeExerciseHistoryEntry(deletedData)
        
        print(realm.objects(ExerciseHistoryEntry.self))
        
        layoutIfNeeded()
        updateCompleteStatus()
    }
}
