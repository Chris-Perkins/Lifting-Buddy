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
    private static let viewPadding: CGFloat = 15.0
    
    // Title bar properties
    
    // the title of this cell, holds the title of the exercise name
    private let cellTitle: UILabel
    // Cell contents on expand
    private let setLabel: UILabel
    // add a set to the table
    private let addSetButton: PrettyButton
    // The actual table view where we input data
    private let setTableView: SetTableView
    // The height of our tableview
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // Exercise assigned to this cell
    private var exercise: Exercise
    // Whether or not this exercise is complete
    private var isComplete: Bool
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
        
        cellTitle    = UILabel()
        setLabel     = UILabel()
        addSetButton = PrettyButton()
        setTableView = SetTableView(forExercise: exercise)
        
        data = [[Float]]()
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        curSet = 1
        isComplete = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(cellTitle)
        addSubview(setTableView)
        addSubview(addSetButton)
        
        createAndActivateCellTitleConstraints()
        createAndActivateAddSetButtonConstraints()
        createAndActivateSetTableViewConstraints()
        
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
        let curSetCount: Int = setTableView.getData().count
        let reqSetCount: Int = exercise.getSetCount()
        /* Text depends on whether or not we have a required set amount.
         * If we do, a format example is [1/2]
         * If we don't, the same example is [1]
         */
        cellTitle.text = reqSetCount > 0 ?
            "[\(curSetCount)/\(reqSetCount)] \(exercise.getName()!)":
        "[\(curSetCount)] \(exercise.getName()!)"
        cellTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        // Add Set button
        addSetButton.setDefaultProperties()
        addSetButton.setTitle(NSLocalizedString("SessionView.Button.AddSet", comment: ""), for: .normal)
        
        // Exercisehistory table
        setTableView.isScrollEnabled = false
        
        // Different states for whether the cell is complete or not.
        // If complete: cell turns green, title color turns white to be visible.
        // If not complete: Cell is white
        if isComplete {
            backgroundColor     = UIColor.niceGreen.withAlphaComponent(0.75)
            cellTitle.textColor = .white
        } else {
            backgroundColor     = .primaryBlackWhiteColor
            cellTitle.textColor = .niceBlue
        }
    }
    
    // MARK: View functions
    
    // Sets the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
    }
    
    // Update the complete status (call when some value changed)
    public func updateCompleteStatus() {
        let newComplete = setTableView.getData().count >= exercise.getSetCount()
        
        // We updated our completed status! So inform the delegate.
        if newComplete != isComplete {
            isComplete = newComplete
            delegate?.cellCompleteStatusChanged(complete: isComplete)
            layoutIfNeeded()
        }
    }
    
    // gets the height of this cell when expanded
    private func getHeight() -> CGFloat {
        // total padding for this view. Incremement by one per each "cell" of this view
        var totalPadding = 0
        
        let titleBarHeight = UITableViewCell.defaultHeight
        let contentHeight = getContentHeight()
        
        let addSetButtonHeight = PrettyButton.defaultHeight
        
        let totalTableViewHeight = WorkoutSessionTableViewCell.viewPadding +
            tableViewHeightConstraint!.constant
        let expandButtonHeight = PrettyButton.defaultHeight * 0.75
        totalPadding += 1
        
        // Swift compiler doesn't like if we do too much addition at once. :-)
        let heightTop = titleBarHeight + contentHeight + addSetButtonHeight
        let heightBottom = expandButtonHeight + totalTableViewHeight
        
        return heightTop + heightBottom +
            CGFloat(totalPadding) *  WorkoutSessionTableViewCell.viewPadding
    }
    
    // gets the height of the content view
    private func getContentHeight() -> CGFloat {
        return  WorkoutSessionTableViewCell.viewPadding +
            CGFloat(exercise.getProgressionMethods().count) * BetterTextField.defaultHeight
    }
    
    private func heightConstraintConstantCouldChange() {
        if let tableViewHeightConstraint = tableViewHeightConstraint
        {
            tableViewHeightConstraint.constant = setTableView.getHeight()
            delegate?.cellHeightDidChange(height: getHeight(), indexPath: indexPath!)
            
            layoutIfNeeded()
        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case addSetButton:
            
            setTableView.layoutIfNeeded()
            setTableView.reloadData()
            updateCompleteStatus()
            layoutIfNeeded()
        default:
            fatalError("Button pressed did not exist?")
        }
    }
    
    // MARK: Encapsulated methods
    
    // Returns whether or not this exercise is complete (did all sets)
    public func getIsComplete() -> Bool {
        return isComplete
    }
    
    // MARK: Constraints
    
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
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitle,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // center horiz to self ; width of addset ; place below addset ; height of tableviewheight
    private func createAndActivateSetTableViewConstraints() {
        setTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setTableView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setTableView,
                                                             withCopyView: addSetButton,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: setTableView,
                                                         belowView: cellTitle,
                                                         withPadding: WorkoutSessionTableViewCell.viewPadding).isActive = true
        tableViewHeightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: setTableView,
                                                             height: 0)
        tableViewHeightConstraint?.isActive = true
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
        NSLayoutConstraint.createViewBelowViewConstraint(view: addSetButton,
                                                         belowView: setTableView).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: addSetButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
}


// MARK: HistoryEntryDelegate Extension

extension WorkoutSessionTableViewCell: ExerciseHistoryEntryTableViewDelegate {
    // Called when a cell is deleted
    func dataDeleted(deletedData: ExerciseHistoryEntry) {
        exercise.removeExerciseHistoryEntry(deletedData)
        
        heightConstraintConstantCouldChange()
        
        updateCompleteStatus()
    }
}
