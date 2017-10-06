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
    
    // Exercise assigned to this cell
    private var exercise: Exercise
    // Padding between views
    private var viewPadding: CGFloat = 25.0
    // View that is at the lowest point in the cell besides the complete button
    // Used in constraining the completebutton
    private var lowestViewBesidesCompleteButton: UIView
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
    private var previousSetButton: PrettyButton
    private var setLabel: UILabel
    private var inputContentView: UIView
    private var exerciseInputFields: [TextFieldWithDefault]
    private var deleteSetButton: PrettyButton
    private var nextSetButton: PrettyButton
    private var completeButton: PrettyButton
    
    private var data: [[Float]]
    
    private var curSet: Int
    
    // MARK: Init Functions
    
    init(exercise: Exercise, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.invisButton = PrettyButton()
        self.cellTitle = UILabel()
        self.expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        self.exercise = exercise
        
        self.previousSetButton = PrettyButton()
        self.setLabel = UILabel()
        self.inputContentView = UIView()
        self.exerciseInputFields = [TextFieldWithDefault]()
        self.deleteSetButton = PrettyButton()
        self.nextSetButton = PrettyButton()
        self.completeButton = PrettyButton()
        
        self.data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        self.curSet = 1
        self.lowestViewBesidesCompleteButton = cellTitle
        self.isComplete = false
        self.isToggled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(invisButton)
        self.addSubview(cellTitle)
        self.addSubview(expandImage)
        self.addSubview(previousSetButton)
        self.addSubview(inputContentView)
        self.addSubview(nextSetButton)
        self.addSubview(completeButton)
        
        self.createAndActivateInvisButtonConstraints()
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivatePreviousButtonConstraints()
        self.createAndActivateInputContentViewConstraints()
        self.createAndActivateInputFieldsConstraints()
        self.createAndActivateNextButtonConstraints()
        self.createAndActivateCompleteButtonConstraints()
        
        self.giveInvisButtonProperties()
        
        self.completeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.nextSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.previousSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
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
        
        self.completeButton.setDefaultProperties()
        
        if (self.isToggled) {
            self.backgroundColor = UIColor.niceLightGreen()
        } else {
            self.backgroundColor = UIColor.white
        }
        
        self.previousSetButton.setDefaultProperties()
        self.previousSetButton.backgroundColor = UIColor.niceGreen()
        
        self.nextSetButton.setDefaultProperties()
        self.nextSetButton.backgroundColor = UIColor.niceGreen()
        
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
        
        if self.curSet == 1 {
            self.previousSetButton.backgroundColor = UIColor.niceGray()
            self.previousSetButton.isUserInteractionEnabled = false
        } else {
            self.previousSetButton.backgroundColor = UIColor.niceGreen()
            self.previousSetButton.isUserInteractionEnabled = true
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
        let titleBarHeight = WorkoutTableView.baseCellHeight
        let completeHeight = WorkoutTableView.baseCellHeight
        // content is where we input our information.
        // we add + 1 to progressionmethods to account for the repetitions we did
        let contentHeight = getContentHeight()
        
        return titleBarHeight + completeHeight + contentHeight
    }
    
    // gets the height of the content view
    private func getContentHeight() -> CGFloat {
        return self.viewPadding * 2 + CGFloat(self.exercise.getProgressionMethods().count + 1) * 40.0
    }
    
    // saves workout data
    // Returns true if successful
    private func saveWorkoutDataWithSuccess() -> Bool{
        var invalidFieldExists = false
        
        for (index, inputField) in self.exerciseInputFields.enumerated() {
            if inputField.text?.floatValue != nil {
                print(inputField.text?.floatValue ?? "EMPTY")
                if self.data.count < self.curSet {
                    self.data.append([Float]())
                }
                if self.data[curSet - 1].count <= index {
                    self.data[curSet - 1].append(inputField.text!.floatValue!)
                }
            } else {
                invalidFieldExists = true
                inputField.backgroundColor = UIColor.niceRed()
                inputField.text = ""
            }
        }
        
        return !invalidFieldExists
    }
    
    private func loadWorkoutDataIfPossible() {
        // If we're out of range, do nothing
        if self.curSet < 0 || self.curSet > self.data.count {
            for inputField in self.exerciseInputFields {
                inputField.text = ""
            }
            
            // Return, as there is no data here yet.
            return
        }
        
        for (index, inputField) in self.exerciseInputFields.enumerated() {
            if index < self.data[curSet - 1].count {
                // set the default string here to the previous string
                inputField.setDefaultString(defaultString: inputField.text)
                inputField.text = String(self.data[curSet - 1][index])
            }
        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case completeButton:
            self.isComplete = !self.isComplete
            self.delegate?.cellCompleteStatusChanged(complete: self.isComplete)
            self.layoutIfNeeded()
            break
        case invisButton:
            self.isToggled = !self.isToggled
            
            if self.isToggled {
                self.delegate?.cellToggled(indexPath: indexPath!)
            }
            
            self.updateToggledStatus()
        case nextSetButton:
            // If unable to save, do nothing.
            if !saveWorkoutDataWithSuccess() {
                return
            }
            
            // increment
            self.curSet += 1
            
            self.loadWorkoutDataIfPossible()
            self.layoutIfNeeded()
            
            break
        case previousSetButton:
            // If unable to save, do nothing.
            if !saveWorkoutDataWithSuccess() {
                return
            }
            
            if curSet > 1 {
                self.curSet -= 1
            }
            
            self.loadWorkoutDataIfPossible()
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
        
        NSLayoutConstraint(item: previousSetButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: inputContentView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: nextSetButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: inputContentView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
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
        
        let repInput = TextFieldWithDefault(defaultString:
                                            (self.exercise.getRepCount() == 0 ?
                                            nil : String(self.exercise.getRepCount())),
                                            frame: .zero)
        repInput.setDefaultProperties()
        
        inputContentView.addSubview(repInput)
        
        repInput.placeholder = "Rep Count"
        repInput.backgroundColor = UIColor.white
        self.addConstraintsToInputView(view: repInput, prevView: prevView)
        self.exerciseInputFields.append(repInput)
        
        prevView = repInput
        
        for progressionMethod in self.exercise.getProgressionMethods().toArray() {
            let progressionInput = TextFieldWithDefault(defaultString: nil, frame: .zero)
            progressionInput.setDefaultProperties()
            
            inputContentView.addSubview(progressionInput)
            
            progressionInput.placeholder = progressionMethod.getName()
            progressionInput.backgroundColor = UIColor.white
            
            self.addConstraintsToInputView(view: progressionInput, prevView: prevView)
            self.exerciseInputFields.append(progressionInput)
            
            prevView = progressionInput
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
    
    // width of this view / 10 ; cling to left of this ; below invisButton ; height of contentView
    private func createAndActivatePreviousButtonConstraints() {
        previousSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: previousSetButton,
                           attribute: .width,
                           multiplier: 10,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: previousSetButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: invisButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: previousSetButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: previousSetButton,
                                                         height: getContentHeight()).isActive = true
        
    }
    
    // width of this view / 10 ; cling to RIGHT of this ; below invisButton ; height of contentView
    private func createAndActivateNextButtonConstraints() {
        nextSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nextSetButton,
                           attribute: .width,
                           multiplier: 10,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: nextSetButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: invisButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: nextSetButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: nextSetButton,
                                                         height: getContentHeight()).isActive = true
        
    }
    
    // width of this view ; cling to left of this ; previousSet ; height of baseheight
    private func createAndActivateCompleteButtonConstraints() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: previousSetButton,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: completeButton,
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
