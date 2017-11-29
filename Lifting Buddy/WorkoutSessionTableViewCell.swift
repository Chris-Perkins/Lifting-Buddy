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

class WorkoutSessionTableViewCell: UITableViewCell, TableViewDelegate {
    
    // MARK: View properties
    
    // Padding between views
    private let viewPadding: CGFloat = 15.0
    // Table view height for expansion
    private let tableViewHeight: CGFloat = 150.0
    
    // Exercise assigned to this cell
    private var exercise: Exercise
    // Whether or not this exercise is complete
    private var isComplete: Bool
    // Holds whether this view is toggled
    private var isToggled: Bool
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: WorkoutSessionTableViewCellDelegate?
    
    // Title bar properties
    
    // the button we press to toggle this cell. It's invisible (basically)
    private var invisButton: PrettyButton
    // the title of this cell, holds the title of the exercise name
    private var cellTitle: UILabel
    // An image that shows whether or not this cell is expanded
    private var expandImage: UIImageView
    
    // Cell contents on expand
    private var setLabel: UILabel
    // view where we put the input textfields
    private var inputContentView: UIView
    // the fields themselves in the inputcontent view
    private var exerciseInputFields: [InputViewHolder]
    // add a set to the table
    private var addSetButton: PrettyButton
    // table view that holds the history of our exercise this go around
    private var exerciseHistoryTableView: ExerciseHistoryTableView
    
    private var data: [[Float]]
    
    private var curSet: Int
    
    // MARK: Init Functions
    
    init(exercise: Exercise, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.invisButton = PrettyButton()
        self.cellTitle = UILabel()
        self.expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        self.exercise = exercise
        
        self.setLabel = UILabel()
        self.inputContentView = UIView()
        self.exerciseInputFields = [InputViewHolder]()
        self.addSetButton = PrettyButton()
        self.exerciseHistoryTableView = ExerciseHistoryTableView(forExercise: exercise,
                                                                 style: .plain)
        
        self.data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        self.curSet = 1
        self.isComplete = false
        self.isToggled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.invisButton)
        self.addSubview(self.cellTitle)
        self.addSubview(self.expandImage)
        self.addSubview(self.inputContentView)
        self.addSubview(self.addSetButton)
        self.addSubview(self.exerciseHistoryTableView)
        
        self.createAndActivateInvisButtonConstraints()
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivateInputContentViewConstraints()
        self.createAndActivateInputFieldsConstraints()
        self.createAndActivateAddSetButtonConstraints()
        self.createAndActivateExerciseHistoryTableViewConstraints()
        
        self.giveInvisButtonProperties()
        
        self.exerciseHistoryTableView.tableViewDelegate = self
        self.addSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        // Self stuff
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        
        // Cell Title
        let curSetCount: Int = self.exerciseHistoryTableView.getData().count
        let reqSetCount: Int = self.exercise.getSetCount()
        /* Text depends on whether or not we have a required set amount.
         * If we do, a format example is [1/2]
         * If we don't, the same example is [1]
         */
        self.cellTitle.text = reqSetCount > 0 ?
                                "[\(curSetCount)/\(reqSetCount)] \(self.exercise.getName()!)":
                                "[\(curSetCount)] \(self.exercise.getName()!)"
        self.cellTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        // Invisible Button has to be "visible" to be pressed. So, 0.001
        self.invisButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        
        // Add Set button
        self.addSetButton.setDefaultProperties()
        self.addSetButton.setTitle("Add Set", for: .normal)
        
        // Different states for whether the cell is complete or not.
        // If complete: cell turns green, title color turns white to be visible.
        // If not complete: Cell is white
        if self.isComplete {
            self.backgroundColor = UIColor.niceGreen.withAlphaComponent(self.isToggled ? 0.85 : 0.75)
            self.cellTitle.textColor = UIColor.white
        } else {
            self.backgroundColor = self.isToggled ? UIColor.niceLightGray : UIColor.white
            self.cellTitle.textColor = UIColor.niceBlue
        }
    }
    
    // MARK: View functions
    
    // Sets the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
    }
    
    // Changes whether or not this cell is toggled
    public func updateToggledStatus() {
        if self.indexPath != nil {
            self.delegate?.cellHeightDidChange(height: self.getHeight(),
                                               indexPath: indexPath!)
            self.expandImage.transform = CGAffineTransform(scaleX: 1,
                                                           y: self.isToggled ? -1 : 1)
        }
    }
    
    // Gets the height of the current cell
    private func getHeight() -> CGFloat {
        return self.isToggled ? getExpandedHeight() : UITableViewCell.defaultHeight
    }

    // gets the height of this cell when expanded
    private func getExpandedHeight() -> CGFloat {
        // total padding for this view. Incremement by one per each "cell" of this view
        var totalPadding = 0
        
        let titleBarHeight = UITableViewCell.defaultHeight
        let contentHeight = getContentHeight()
        
        let addSetButtonHeight = PrettyButton.defaultHeight
        totalPadding += 1
        
        let totalTableViewHeight = self.tableViewHeight + self.viewPadding
        totalPadding += 1
        
        // Swift compiler doesn't like if we do too much addition at once. :-)
        let heightTop = titleBarHeight + contentHeight + addSetButtonHeight
        let heightBottom = totalTableViewHeight
        
        return heightTop + heightBottom + CGFloat(totalPadding) * self.viewPadding
    }
    
    // gets the height of the content view
    private func getContentHeight() -> CGFloat {
        return self.viewPadding * 2 + CGFloat(self.exercise.getProgressionMethods().count) * 40.0
    }
    
    // saves workout data
    // Returns true if successful
    private func addWorkoutDataToTableIfPossible() {
        var canAddSet = true
        for inputField in self.exerciseInputFields {
            if !(inputField.areFieldsValid()) {
                canAddSet = false
            }
        }
        
        if canAddSet {
            var exerciseData = [String]()
            // todo: add to tableview
            for inputField in self.exerciseInputFields {
                exerciseData.append(inputField.getValue())
            }
            
            self.exerciseHistoryTableView.appendDataToTableView(data: exerciseData)
        }
    }
    
    // Update the complete status (call when some value changed)
    public func updateCompleteStatus() {
        let newComplete = self.exerciseHistoryTableView.getData().count >= self.exercise.getSetCount()
        
        // We updated our completed status! So inform the delegate.
        if newComplete != self.isComplete {
            self.isComplete = newComplete
            self.delegate?.cellCompleteStatusChanged(complete: self.isComplete)
            self.layoutIfNeeded()
        }
    }
    
    // adds workout data to history
    public func saveWorkoutData() {

        for exerciseHistoryCell in self.exerciseHistoryTableView.getAllCells() as! [ExerciseHistoryTableViewCell] {
            let exerciseEntry = ExerciseHistoryEntry()
            exerciseEntry.date = Date(timeIntervalSinceNow: 0)
            exerciseEntry.exerciseInfo = List<RLMExercisePiece>()
            
            for data in exerciseHistoryCell.getData() {
                let exercisePiece = RLMExercisePiece()
                exercisePiece.progressionMethod = data.0
                exercisePiece.value = data.1
                
                exerciseEntry.exerciseInfo.append(exercisePiece)
                
                data.0.setDefaultValue(defaultValue: data.1)
            }
            
            exercise.appendExerciseHistoryEntry(exerciseHistoryEntry: exerciseEntry)
        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case self.invisButton:
            self.isToggled = !self.isToggled
            self.updateToggledStatus()
        case self.addSetButton:
            self.addWorkoutDataToTableIfPossible()
            self.exerciseHistoryTableView.layoutIfNeeded()
            self.exerciseHistoryTableView.reloadData()
            self.updateCompleteStatus()
            self.layoutIfNeeded()
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Encapsulated methods
    
    // Set whether or not this cell is toggled
    public func setIsToggled(toggled: Bool) {
        self.isToggled = toggled
        self.updateToggledStatus()
    }
    
    public func getIsComplete() -> Bool {
        return self.isComplete
    }
    
    // MARK: TableViewDelegate Functions
    
    // Called when a cell is deleted
    func cellDeleted() {
        self.layoutIfNeeded()
        self.updateCompleteStatus()
    }
    
    // MARK: Constraints
    
    // Cling to top, left, right ; height of baseviewcell
    private func createAndActivateInvisButtonConstraints() {
        self.invisButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.invisButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.invisButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.invisButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: invisButton,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Place below view top, cling to left, right ; height of default height
    private func createAndActivateCellTitleConstraints() {
        self.cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: self.expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Cling to top, right ;  height 8.46 ; width 16
    private func createAndActivateExpandImageConstraints() {
        self.expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: self.expandImage,
                                                        width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.expandImage,
                                                         height: 8.46).isActive = true
    }
    
    private func createAndActivateInputContentViewConstraints() {
        self.inputContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.inputContentView,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 25).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.inputContentView,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -25).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.inputContentView,
                                                         belowView: self.invisButton).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: inputContentView,
                                                         height: getContentHeight()).isActive = true
    }
    
    // create the input fields in the center field
    private func createAndActivateInputFieldsConstraints() {
        var prevView = inputContentView
        
        for progressionMethod in self.exercise.getProgressionMethods() {
            if progressionMethod.getUnit() != ProgressionMethod.Unit.TIME.rawValue {
                let progressionInput = BetterInputView(args: [(
                                                               progressionMethod.getName(),
                                                               progressionMethod.getDefaultValue() ?? progressionMethod.getName(),
                                                               true
                                                             )], frame: .zero)
                inputContentView.addSubview(progressionInput)
                
                progressionInput.backgroundColor = UIColor.white
                
                self.addConstraintsToInputView(view: progressionInput, prevView: prevView)
                self.exerciseInputFields.append(progressionInput)
                
                prevView = progressionInput
            } else {
                let progressionInput = TimeInputField(frame: .zero)
                
                self.inputContentView.addSubview(progressionInput)
                self.addConstraintsToInputView(view: progressionInput, prevView: prevView)
                self.exerciseInputFields.append(progressionInput)
                
                prevView = progressionInput
            }
        }
    }
    
    // Add the constraints to the input we just created
    private func addConstraintsToInputView(view: UIView, prevView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: self.inputContentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: self.inputContentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: prevView,
                           attribute: prevView == self.inputContentView ? .top : .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .top,
                           multiplier: 1,
                           constant: prevView == self.inputContentView ? -viewPadding : 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: view,
                                                         height: 40).isActive = true
    }
    
    // Place below the input content view
    private func createAndActivateAddSetButtonConstraints() {
        self.addSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addSetButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.addSetButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.75).isActive = true
        NSLayoutConstraint(item: self.inputContentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.addSetButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: -self.viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addSetButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // center horiz in view ; width of this view/1.33 ; place below add set button ; height of tableviewheight
    private func createAndActivateExerciseHistoryTableViewConstraints() {
        self.exerciseHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseHistoryTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exerciseHistoryTableView,
                                                             withCopyView: self.addSetButton,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint(item: self.addSetButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.exerciseHistoryTableView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -self.viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.exerciseHistoryTableView,
                                                         height: self.tableViewHeight).isActive = true
    }
    
    // MARK: view properties assigned
    
    // Gives the invisible button the properties it needs to function
    private func giveInvisButtonProperties() {
        invisButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
}

protocol WorkoutSessionTableViewCellDelegate {
    /*
     * This cell height changed
     */
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    /*
     * This cell's completion status changed
     */
    func cellCompleteStatusChanged(complete: Bool)
}
