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
    private var exerciseInputFields: [UITextField]
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
        self.exerciseInputFields = [UITextField]()
        self.deleteSetButton = PrettyButton()
        self.nextSetButton = PrettyButton()
        self.completeButton = PrettyButton()
        
        self.data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        curSet = 0
        lowestViewBesidesCompleteButton = cellTitle
        isComplete = false
        isToggled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(invisButton)
        self.addSubview(cellTitle)
        self.addSubview(expandImage)
        self.addSubview(previousSetButton)
        self.addSubview(nextSetButton)
        self.addSubview(completeButton)
        
        self.createAndActivateInvisButtonConstraints()
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivatePreviousButtonConstraints()
        self.createAndActivateNextButtonConstraints()
        self.createAndActivateCompleteButtonConstraints()
        
        self.giveInvisButtonProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        cellTitle.text = self.exercise.getName()
        
        invisButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        completeButton.setDefaultProperties()
        completeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        if (self.isToggled) {
            self.backgroundColor = UIColor.niceLightGreen()
        } else {
            self.backgroundColor = UIColor.white
        }
        
        previousSetButton.setDefaultProperties()
        previousSetButton.backgroundColor = UIColor.niceGreen()
        
        nextSetButton.setDefaultProperties()
        nextSetButton.backgroundColor = UIColor.niceGreen()
        
        completeButton.setTitleColor(UIColor.white, for: .normal)
        // Different states for whether the cell is complete or not.
        // If complete: cell turns green, title color turns white to be visible.
        // If not complete: Cell is white
        if self.isComplete {
            // Lighten when not selected
            self.backgroundColor = UIColor.niceGreen().withAlphaComponent(self.isSelected ? 0.65 : 0.5)
            
            cellTitle.textColor = UIColor.white
            
            completeButton.setTitle("Mark Incomplete", for: .normal)
            completeButton.setTitleColor(UIColor.white, for: .normal)
            completeButton.backgroundColor = UIColor.niceRed().withAlphaComponent(0.9)
        } else {
            cellTitle.textColor = UIColor.niceBlue()
            
            completeButton.setTitle("Complete Exercise", for: .normal)
            completeButton.backgroundColor = UIColor.niceBlue()
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
            delegate?.cellHeightDidChange(height: self.getHeight(),
                                          indexPath: indexPath!)
            self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isToggled ? -1 : 1)
        }
    }
    
    // Gets the height of the current cell
    private func getHeight() -> CGFloat {
        return self.isToggled ? getExpandedHeight() : WorkoutStartTableView.baseCellHeight
    }

    private func getExpandedHeight() -> CGFloat {
        let titleBarHeight = WorkoutTableView.baseCellHeight
        let completeHeight = WorkoutTableView.baseCellHeight
        // content is where we input our information.
        // we add + 1 to progressionmethods to account for the repetitions we did
        let contentHeight = getContentHeight()
        
        return titleBarHeight + completeHeight + contentHeight
    }
    
    private func getContentHeight() -> CGFloat {
        return viewPadding * 2.5 + CGFloat(exercise.getProgressionMethods().count + 1) * 20.0
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case completeButton:
            self.isComplete = !self.isComplete
            delegate?.cellCompleteStatusChanged(complete: self.isComplete)
            self.layoutIfNeeded()
            break
        case invisButton:
            self.isToggled = !self.isToggled
            
            if self.isToggled {
                delegate?.cellToggled(indexPath: indexPath!)
            }
            
            self.updateToggledStatus()
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Encapsulated methods
    
    public func setIsToggled(toggled: Bool) {
        self.isToggled = toggled
        updateToggledStatus()
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
