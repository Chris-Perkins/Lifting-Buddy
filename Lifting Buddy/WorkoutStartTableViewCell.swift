//
//  WorkoutStartTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableViewCell: UITableViewCell, ExerciseTableViewDelegate {
    
    // MARK: View properties
    
    // Exercise assigned to this cell
    private var exercise: Exercise?
    // Height of this cell
    private var heightConstraint: NSLayoutConstraint?
    // Current height of the cell
    private var curHeight: CGFloat
    // Padding between views
    private var viewPadding: CGFloat = 25.0
    // View that is at the lowest point in the cell besides the complete button
    // Used in constraining the completebutton
    private var lowestViewBesidesCompleteButton: UIView
    // Whether or not this exercise is complete
    private var isComplete: Bool
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: WorkoutStartTableViewCellDelegate?
    
    private var cellTitle: UILabel
    private var exerciseTable: ExerciseTableView?
    private var completeButton: PrettyButton
    
    // MARK: Init Functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        completeButton = PrettyButton()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        // ViewPadding * 2 to take into account tableview
        curHeight = WorkoutStartTableView.baseCellHeight * 2
        lowestViewBesidesCompleteButton = cellTitle
        isComplete = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellTitle)
        self.addSubview(completeButton)
        
        self.createAndActivateCellTitleConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        if (self.isSelected) {
            self.backgroundColor = UIColor.niceBlue().withAlphaComponent(0.05)
        } else {
            self.backgroundColor = UIColor.white
        }
        
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
            completeButton.backgroundColor = UIColor.niceGreen()
        }
        
        cellTitle.text = exercise?.getName()
        
        completeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        completeButton.setOverlayStyle(style: .FADE)
        completeButton.setOverlayColor(color: UIColor.niceYellow())
    }
    
    // MARK: ExerciseStartTableViewCellMethods
    
    func heightChange(addHeight: CGFloat) {
        curHeight += addHeight
        
        delegate?.cellHeightDidChange(height: self.getHeight(), indexPath: indexPath!)
    }
    
    // MARK: View functions
    
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        exerciseTable?.removeFromSuperview()
        exerciseTable = ExerciseTableView(exercise: exercise, style: .plain, heightDelegate: self)
        exerciseTable!.backgroundColor = UIColor.black
        exerciseTable!.heightDelegate = self
        
        self.addSubview(exerciseTable!)
        
        lowestViewBesidesCompleteButton = exerciseTable!
        
        cellTitle.text = exercise.getName()
        
        self.createAndActivateTableViewConstraints()
        // do this after creating constraints so the constraint is updated properly
        for _ in 0 ..< exercise.getSetCount() {
            exerciseTable?.createCell()
        }
        
        self.updateAndCreateCompleteButtonConstraints()
    }
    
    public func updateSelectedStatus() {
        if indexPath != nil && self.exercise != nil {
            delegate?.cellHeightDidChange(height: self.getHeight(),
                                          indexPath: indexPath!)
        }
    }
    
    private func getHeight() -> CGFloat {
        return self.isSelected ? curHeight : WorkoutStartTableView.baseCellHeight
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case completeButton:
            self.isComplete = !self.isComplete
            delegate?.cellCompleteStatusChanged(complete: self.isComplete)
            self.layoutSubviews()
            break
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Constraints
    
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
    
    private func createAndActivateTableViewConstraints() {
        exerciseTable?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: exerciseTable!,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: exerciseTable!,
                                                         belowView: cellTitle,
                                                         withPadding: 0).isActive = true
        // Create and assign height constraint
        // Assign height constraint
        exerciseTable?.heightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: exerciseTable!,
                                                             height: 0)
        exerciseTable!.heightConstraint?.isActive = true
        
        NSLayoutConstraint.createWidthCopyConstraintForView(view: exerciseTable!,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
    
    private func updateAndCreateCompleteButtonConstraints() {
        // Remove any previous constraints from this view
        completeButton.removeFromSuperview()
        
        completeButton = PrettyButton()
        self.addSubview(completeButton)
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: completeButton,
                                                         belowView: lowestViewBesidesCompleteButton,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: completeButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: completeButton,
                                                         height: WorkoutStartTableView.baseCellHeight).isActive = true
    }
}

protocol WorkoutStartTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}
