//
//  WorkoutSessionTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutSessionTableView: UITableView {
    
    // MARK: View properties
    
    // The delegate for this view
    public var viewDelegate: WorkoutSessionTableViewDelegate?
    
    // Data, holds exercises per cell
    private var data: List<Exercise>
    // cells in this tableview
    public var cells: [WorkoutSessionTableViewCell]
    // Heights per cell
    private var heights: [CGFloat]
    // Whether or not this workout is complete
    private var curComplete: Int
    
    // MARK: Initializers
    
    init(workout: Workout?, frame: CGRect, style: UITableView.Style) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutSessionTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        super.init(frame: frame, style: style)
        
        for _ in data {
            heights.append(UITableViewCell.defaultHeight)
        }
        
        setupTableView()
    }
    
    init(workout: Workout?, style: UITableView.Style) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutSessionTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(UITableViewCell.defaultHeight)
        }
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        heights.append(UITableViewCell.defaultHeight)
        
        let realm = try! Realm()
        try! realm.write {
            self.data.append(data)
        }
        
        reloadData()
        checkComplete()
    }
    
    // Retrieve workouts
    public func getData() -> List<Exercise> {
        return data
    }
    
    // Check if we completed all exercises
    public func checkComplete() {
        if curComplete == data.count {
            viewDelegate?.updateCompleteStatus(isComplete: true)
        } else {
            viewDelegate?.updateCompleteStatus(isComplete: false)
        }
    }
    
    // Setup the table view to default properties
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        register(WorkoutSessionTableViewCell.self,
                 forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
}


// MARK: DataSource extension

extension WorkoutSessionTableView: UITableViewDataSource {
    // Moved a cell (HPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.write {
            data.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        }
        
        cells.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        heights.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(at: indexPath.row)
        }
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= cells.count {
            let cell = WorkoutSessionTableViewCell(exercise: data[indexPath.row],
                                                   style: .default,
                                                   reuseIdentifier: nil)
            
            cell.delegate         = self
            cell.deletionDelegate = self
            cell.scrollDelegate   = self
            cell.indexPath        = indexPath
            
            cell.updateCompleteStatus()
            cell.updateToggledStatus()
            cell.heightConstraintConstantCouldChange()
            
            cells.append(cell)
            return cell
        } else {
            cells[indexPath.row].indexPath = indexPath
            return cells[indexPath.row]
        }
    }
}


// MARK: TableViewDelegate extension

extension WorkoutSessionTableView: UITableViewDelegate {
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
}


// MARK: WorkoutSessionTableViewCellDelegate extension

extension WorkoutSessionTableView: WorkoutSessionTableViewCellDelegate {
    // Height of a cell changed ; update this view's height to match height change
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath) {
        heights[indexPath.row] = height
        reloadData()
        
        viewDelegate?.heightChange()
    }
    
    // Update complete count, check if we completed all exercises
    func cellCompleteStatusChanged(complete: Bool) {
        curComplete += complete ? 1 : -1
        checkComplete()
    }
}


// MARK: CellDeletionDelegate Extension

extension WorkoutSessionTableView: CellDeletionDelegate {
    // Deletes all data that we can
    func deleteData(at index: Int) {
        /*
            We need check if < cells.count because cells are not all generated at once.
        */
        if index < cells.count {
            if cells[index].getIsComplete() {
                /* if this cell was complete, make sure that we remove it from curComplete int! */
                curComplete -= 1
            }
            
            cells.remove(at: index)
        }
        
        // Attempt to remove the exercise from AppDelegate + realm
        let exercise = data[index]
        sessionExercises.remove(exercise)
        let realm = try! Realm()
        try! realm.write {
            data.remove(at: index)
        }
        
        // If still in realm, the exercise had multiple of the exercise.
        // So, don't delete the exercise from the set.
        if data.contains(exercise) {
            sessionExercises.insert(exercise)
        }
        
        
        heights.remove(at: index)
        checkComplete()
        reloadData()
    }
}

extension WorkoutSessionTableView: UITableViewScrollDelegate {
    /*
     * We have this here as if we scroll to bottom if we add a cell, but we scroll to the top
     * If we expand/collapse the cell. This causes differing behaviors, and therefore this is
     * necessary... but not necessarily pretty.
     */
    func scrollToCell(atIndexPath indexPath: IndexPath, position: UITableView.ScrollPosition,
                      animated: Bool) {
        scrollToRow(at: indexPath, at: position, animated: animated)
    }
}

extension WorkoutSessionTableView: HPReorderTableViewDelegate {
    func tableView(_ tableView: UITableView!, willBeginCellReorderAt indexPath: IndexPath!) {
        for cell in cells {
            cell.isToggled = false
            cell.updateToggledStatus()
        }
    }
}
