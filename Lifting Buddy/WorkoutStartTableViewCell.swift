//
//  WorkoutStartTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // Padding between views
    private let viewPadding: CGFloat = 15.0
    // Table view height for expansion
    private let tableViewHeight: CGFloat = 150.0
    
    // Exercise assigned to this cell
    private var exercise: Exercise
    // View that is at the lowest point in the cell besides the complete button
    // Used in constraining the completebutton
    private var lowestInputView: UIView
    // Whether or not this exercise is complete
    private var isComplete: Bool
    // Holds whether this view is toggled
    private var isToggled: Bool
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: WorkoutStartTableViewCellDelegate?
    
    // Title bar properties
    private var invisButton: PrettyButton
    private var cellTitle: UILabel
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
    // a button to complete the workout
    private var completeButton: PrettyButton
    
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
        self.exerciseHistoryTableView = ExerciseHistoryTableView()
        self.completeButton = PrettyButton()
        
        self.data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        self.curSet = 1
        self.lowestInputView = cellTitle
        self.isComplete = false
        self.isToggled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.invisButton)
        self.addSubview(self.cellTitle)
        self.addSubview(self.expandImage)
        self.addSubview(self.inputContentView)
        self.addSubview(self.addSetButton)
        self.addSubview(self.exerciseHistoryTableView)
        self.addSubview(self.completeButton)
        
        self.createAndActivateInvisButtonConstraints()
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivateInputContentViewConstraints()
        self.createAndActivateInputFieldsConstraints()
        self.createAndActivateAddSetButtonConstraints()
        self.createAndActivateExerciseHistoryTableViewConstraints()
        self.createAndActivateCompleteButtonConstraints()
        
        self.giveInvisButtonProperties()
        
        self.addSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.completeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        self.cellTitle.text = self.exercise.getName()
        
        self.invisButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        self.addSetButton.setDefaultProperties()
        self.addSetButton.setTitle("Add Set", for: .normal)
        
        self.completeButton.setDefaultProperties()
        
        if (self.isToggled) {
            self.backgroundColor = UIColor.niceLightGreen()
        } else {
            self.backgroundColor = UIColor.white
        }
        
        self.cellTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.completeButton.setTitleColor(UIColor.white, for: .normal)
        
        // Different states for whether the cell is complete or not.
        // If complete: cell turns green, title color turns white to be visible.
        // If not complete: Cell is white
        if self.isComplete {
            // Lighten when not selected
            self.backgroundColor = UIColor.niceGreen().withAlphaComponent(self.isSelected ? 0.65 : 0.5)
            
            self.cellTitle.textColor = UIColor.white
            
            self.completeButton.setTitle("Mark Incomplete", for: .normal)
            self.completeButton.setTitleColor(UIColor.white, for: .normal)
            self.completeButton.backgroundColor = UIColor.niceRed().withAlphaComponent(0.9)
        } else {
            self.cellTitle.textColor = UIColor.niceBlue()
            
            self.completeButton.setTitle("Complete Exercise", for: .normal)
            self.completeButton.backgroundColor = UIColor.niceBlue()
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
            self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isToggled ? -1 : 1)
        }
    }
    
    // Gets the height of the current cell
    private func getHeight() -> CGFloat {
        return self.isToggled ? getExpandedHeight() : WorkoutStartTableView.baseCellHeight
    }

    // gets the height of this cell when expanded
    private func getExpandedHeight() -> CGFloat {
        // total padding for this view. Incremement by one per each "cell" of this view
        var totalPadding = 0
        
        let titleBarHeight = WorkoutTableView.baseCellHeight
        let contentHeight = getContentHeight()
        
        let addSetButtonHeight = WorkoutTableView.baseCellHeight
        totalPadding += 1
        
        let totalTableViewHeight = self.tableViewHeight + self.viewPadding
        totalPadding += 1
        
        let completeButtonHeight = WorkoutTableView.baseCellHeight
        
        let heightTop = titleBarHeight + contentHeight + addSetButtonHeight
        let heightBottom = totalTableViewHeight + completeButtonHeight
        
        return heightTop + heightBottom + CGFloat(totalPadding) * self.viewPadding
    }
    
    // gets the height of the content view
    private func getContentHeight() -> CGFloat {
        return self.viewPadding * 2 + CGFloat(self.exercise.getProgressionMethods().count + 1) * 40.0
    }
    
    // saves workout data
    // Returns true if successful
    private func addWorkoutDataToTableIfPossible() {
//        for inputField in self.exerciseInputFields {
//            if let view: BetterTextField = inputField as? BetterTextField {
//                if view.text?.floatValue != nil {
//                    print(view.text?.floatValue ?? "EMPTY")
//                } else {
//                    inputField.backgroundColor = UIColor.niceRed()
//                    view.text = ""
//                }
//            }
//        }
        var canAddSet = true
        for inputField in self.exerciseInputFields {
            if !(inputField.areFieldsValid()) {
                canAddSet = false
            }
        }
        
        if canAddSet {
            // todo: add to tableview
        }
    }
    
    private func loadWorkoutDataIfPossible() {
        // If we're out of range, do nothing
//        if self.curSet < 0 || self.curSet > self.data.count {
//            for inputField in self.exerciseInputFields {
//                inputField.text = ""
//            }
//
//            // Return, as there is no data here yet.
//            return
//        }
//
//        for (index, inputField) in self.exerciseInputFields.enumerated() {
//            if index < self.data[curSet - 1].count {
//                // set the default string here to the previous string
//                inputField.setDefaultString(defaultString: inputField.text)
//                inputField.text = String(self.data[curSet - 1][index])
//            }
//        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case self.invisButton:
            self.isToggled = !self.isToggled
            
            if self.isToggled {
                self.delegate?.cellToggled(indexPath: indexPath!)
            }
            
            self.updateToggledStatus()
        case self.addSetButton:
            self.addWorkoutDataToTableIfPossible()
            break
        case self.completeButton:
            self.isComplete = !self.isComplete
            self.delegate?.cellCompleteStatusChanged(complete: self.isComplete)
            self.layoutIfNeeded()
            break
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Encapsulated methods
    
    public func setIsToggled(toggled: Bool) {
        self.isToggled = toggled
        self.updateToggledStatus()
    }
    
    // MARK: Constraints
    
    // Cling to top, left, right ; height of baseviewcell
    private func createAndActivateInvisButtonConstraints() {
        invisButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: invisButton,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: invisButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: invisButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: invisButton,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
    }
    
    // Place below view top, cling to left, right ; height of baseCellHeight
    private func createAndActivateCellTitleConstraints() {
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: cellTitle,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
    }
    
    // Cling to top, right ;  height 8.46 ; width 16
    private func createAndActivateExpandImageConstraints() {
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage, width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage, height: 8.46).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: expandImage,
                                                            belowView: self,
                                                            withPadding: 20.77).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: expandImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
    }
    
    private func createAndActivateInputContentViewConstraints() {
        inputContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: inputContentView,
                           attribute: .left,
                           multiplier: 1,
                           constant: -25).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: inputContentView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 25).isActive = true
        NSLayoutConstraint(item: invisButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: inputContentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: inputContentView,
                                                         height: getContentHeight()).isActive = true
    }
    
    // create the input fields in the center field
    private func createAndActivateInputFieldsConstraints() {
        var prevView = inputContentView
        
        let repInput = BetterInputView(args: [(
                                               "Reps",
                                               String(self.exercise.getRepCount()),
                                               true
                                             )],
                                             frame: .zero)
        
        inputContentView.addSubview(repInput)
        
        self.addConstraintsToInputView(view: repInput, prevView: prevView)
        self.exerciseInputFields.append(repInput)
        
        prevView = repInput
        
        for progressionMethod in self.exercise.getProgressionMethods().toArray() {
            if progressionMethod.getUnit() != ProgressionMethod.Unit.TIME.rawValue {
                let progressionInput = BetterInputView(args: [(
                                                               progressionMethod.getName(),
                                                               progressionMethod.getName(),
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
        
        NSLayoutConstraint(item: inputContentView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: inputContentView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
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
        self.addSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.addSetButton,
                                                                        inView: self).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.addSetButton,
                           attribute: .width,
                           multiplier: 4/3,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self.inputContentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.addSetButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: -self.viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.addSetButton,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
    }
    
    private func createAndActivateExerciseHistoryTableViewConstraints() {
        self.exerciseHistoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: self.exerciseHistoryTableView,
                                                                        inView: self).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.exerciseHistoryTableView,
                           attribute: .width,
                           multiplier: 4/3,
                           constant: 0).isActive = true
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
    
    // width of this view ; cling to left of this ; previousSet ; height of baseheight
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.completeButton,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.completeButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self.exerciseHistoryTableView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.completeButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: -self.viewPadding).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.completeButton,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
        
    }
    
    // MARK: view properties assigned
    
    // Gives the invisible button the properties it needs to function
    private func giveInvisButtonProperties() {
        invisButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
}

protocol WorkoutStartTableViewCellDelegate {
    /*
     This cell height changed
     */
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    /*
     This cell's completion status changed
     */
    func cellCompleteStatusChanged(complete: Bool)
    
    /*
     This cell is toggled
     */
    func cellToggled(indexPath: IndexPath)
}
