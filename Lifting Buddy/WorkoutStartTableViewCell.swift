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
    private var completeButton: PrettyButton
    
    // MARK: Init Functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        completeButton = PrettyButton()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        curHeight = WorkoutStartTableView.baseCellHeight * 2 + viewPadding
        lowestViewBesidesCompleteButton = cellTitle
        isComplete = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellTitle)
        self.addSubview(completeButton)
        
        self.createAndActivateCellTitleConstraints()
        self.updateAndCreateCompleteButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        if (self.isSelected) {
            self.backgroundColor = UIColor.niceBlue().withAlphaComponent(0.05)
        } else {
            self.backgroundColor = UIColor.white
        }
        
        completeButton.setTitleColor(UIColor.white, for: .normal)
        if self.isComplete {
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
    
    // MARK: View functions
    
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        cellTitle.text = exercise.getName()
    }
    
    public func updateSelectedStatus() {
        if indexPath != nil && self.exercise != nil {
            delegate?.cellHeightDidChange(height: self.isSelected ? curHeight : WorkoutStartTableView.baseCellHeight,
                                          indexPath: indexPath!)
        }
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case completeButton:
            self.isComplete = !self.isComplete
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
    
    private func updateAndCreateCompleteButtonConstraints() {
        // Remove any previous constraints from this view
        completeButton.removeFromSuperview()
        
        completeButton = PrettyButton()
        self.addSubview(completeButton)
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: completeButton,
                                                         belowView: lowestViewBesidesCompleteButton,
                                                         withPadding: viewPadding).isActive = true
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
}
