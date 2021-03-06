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
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: WorkoutSessionTableViewCellDelegate?
    // The delegate we use to indicate that a cell was deleted
    public var deletionDelegate: CellDeletionDelegate?
    // Delegate we inform where to scroll
    public var scrollDelegate: UITableViewScrollDelegate?
    
    // the button we press to toggle this cell. It's invisible (basically)
    private let invisButton: UIButton
    // The button indicating we can expand this cell
    public let expandImage: UIImageView
    // the title of this cell, holds the title of the exercise name
    public let cellTitle: UILabel
    // Cell contents on expand
    public let setLabel: UILabel
    // add a set to the table
    public let addSetButton: PrettyButton
    // The actual table view where we input data
    public let setTableView: SetTableView
    
    // The height of our tableview
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // Exercise assigned to this cell
    private var exercise: Exercise
    // Whether or not this exercise is complete
    private var isComplete: Bool
    // Whether or not this view is toggled
    public var isToggled: Bool
    // The current set we're doing
    private var curSet: Int
    
    // MARK: Init Functions
    
    init(exercise: Exercise, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.exercise = exercise
        
        invisButton  = UIButton()
        cellTitle    = UILabel()
        expandImage  = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        setLabel     = UILabel()
        addSetButton = PrettyButton()
        setTableView = SetTableView(forExercise: exercise)
        
        // Initialize to minimum height of the cell label + the viewPadding associated
        // between the two views.
        curSet     = 0
        isComplete = false
        isToggled  = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(invisButton)
        addSubview(expandImage)
        addSubview(cellTitle)
        addSubview(setTableView)
        addSubview(addSetButton)
        
        createAndActivateInvisButtonConstraints()
        createAndActivateExpandImageConstraints()
        createAndActivateCellTitleConstraints()
        createAndActivateAddSetButtonConstraints()
        createAndActivateSetTableViewConstraints()
        
        invisButton.addTarget( self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        addSetButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        setTableView.completedSetCountDelegate = self
        setTableView.cellDeletionDelegate = self
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
        selectionStyle = .none
        clipsToBounds = true
        
        
        // Invis Button
        // Invis Button has to be "visible" to be pressed. So, 0.001
        invisButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        // Cell Title
        curSet = setTableView.completedSetCount
        let reqSet = exercise.getSetCount()
        
        /*
         * Text depends on whether or not we have a required set amount.
         * If we do, a format example is [1/2]
         * If we don't, the same example is [1]
         */
        cellTitle.text = reqSet > 0 ?
            "[\(curSet)/\(reqSet)] \(exercise.getName()!)":
            "[\(curSet)] \(exercise.getName()!)"
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
        
        updateCompleteStatus()
    }
    
    // MARK: View functions
    
    // Sets the exercise for this cell
    public func setExercise(_ exercise: Exercise) {
        self.exercise = exercise
    }
    
    // Update the complete status (call when some value changed)
    public func updateCompleteStatus() {
        let newComplete = setTableView.completedSetCount >= exercise.getSetCount()
        
        // We updated our completed status! So inform the delegate.
        if newComplete != isComplete {
            isComplete = newComplete
            delegate?.cellCompleteStatusChanged(complete: isComplete)
            
            // We only display the message if the exercise is complete and > 0 sets to do
            if isComplete && exercise.getSetCount() != 0 {
                MessageQueue.shared.append(Message(type: .exerciseComplete,
                                                   identifier: exercise.getName(),
                                                   value: nil))
            }
            layoutSubviews()
        } else if curSet != setTableView.completedSetCount {
            layoutSubviews()
        }
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
    
    // gets the height of this cell when expanded or hidden
    private func getHeight() -> CGFloat {
        if isToggled {
            // total padding for this view. Incremement by one per each "cell" of this view
            var totalPadding = 0
            
            let titleBarHeight = UITableViewCell.defaultHeight
            
            let addSetButtonHeight = PrettyButton.defaultHeight
            let totalTableViewHeight = tableViewHeightConstraint!.constant
            totalPadding += 1
            
            return titleBarHeight + totalTableViewHeight + addSetButtonHeight +
                CGFloat(totalPadding) *  WorkoutSessionTableViewCell.viewPadding
        } else {
            return UITableViewCell.defaultHeight
        }
    }
    
    // Should be called whenever the height constraint may change
    public func heightConstraintConstantCouldChange() {
        if let tableViewHeightConstraint = tableViewHeightConstraint
        {
            tableViewHeightConstraint.constant = setTableView.getHeight()
            delegate?.cellHeightDidChange(height: getHeight(), indexPath: indexPath!)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    // MARK: Event functions
    
    // Generic button press event
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case invisButton:
            isToggled = !isToggled
            updateToggledStatus()
            
            scrollDelegate?.scrollToCell(atIndexPath: indexPath!,
                                         position: .top, animated: false)
        case addSetButton:
            setTableView.appendDataPiece(ExerciseHistoryEntry())
            heightConstraintConstantCouldChange()
            
            // Don't animate as we would cause the tableview to scroll way down every time.
            // that's bad.
            scrollDelegate?.scrollToCell(atIndexPath: indexPath!,
                                         position: .bottom, animated: false)
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
    
    // Cling to top, left, right of self ; height default
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
                                                         height: UITableViewCell.defaultHeight
                                                        ).isActive = true
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
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight
                                                        ).isActive = true
    }
    
    // center horiz to self ; width of addset ; place below addset ; height of tableviewheight
    private func createAndActivateSetTableViewConstraints() {
        setTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setTableView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setTableView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: setTableView,
                                                         belowView: cellTitle,
                                                         withPadding: WorkoutSessionTableViewCell.viewPadding
                                                        ).isActive = true
        tableViewHeightConstraint =
            NSLayoutConstraint.createHeightConstraintForView(view: setTableView,
                                                             height: 0)
        tableViewHeightConstraint!.isActive = true
    }
    
    // Place below the input content view
    private func createAndActivateAddSetButtonConstraints() {
        addSetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addSetButton,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: addSetButton,
                                                             withCopyView: setTableView,
                                                             attribute: .width).isActive = true
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


// MARK: SetTableViewDelegate

extension WorkoutSessionTableViewCell: SetTableViewDelegate {
    func completedSetCountChanged() {
        updateCompleteStatus()
    }
}

extension WorkoutSessionTableViewCell: CellDeletionDelegate {
    func deleteData(at index: Int) {
        tableViewHeightConstraint?.constant -= SetTableViewCell.getHeight(forExercise: exercise)
        heightConstraintConstantCouldChange()
        scrollDelegate?.scrollToCell(atIndexPath: indexPath!, position: .none, animated: false)
    }
}
