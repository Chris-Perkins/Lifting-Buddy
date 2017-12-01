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
import HPReorderTableView

class WorkoutSessionTableView: HPReorderTableView, UITableViewDelegate, UITableViewDataSource,
                             WorkoutSessionTableViewCellDelegate {
    
    // MARK: View properties
    
    // Height constraint for this view
    public var heightConstraint: NSLayoutConstraint?
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
    
    init(workout: Workout?, frame: CGRect, style: UITableViewStyle) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutSessionTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(UITableViewCell.defaultHeight)
        }
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workout: Workout?, style: UITableViewStyle) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutSessionTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(UITableViewCell.defaultHeight)
        }
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
        self.isScrollEnabled = false
    }
    
    // MARK: TableView Functions
    
    override func reloadData() {
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.reloadData()
    }
    
    // Moved a cell (HPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let realm = try! Realm()
        try! realm.write {
            self.data.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        }
        
        self.cells.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < self.cells.count {
                if cells[indexPath.row].getIsComplete() {
                    /* if this cell was complete, make sure that we remove it from curComplete int! */
                    self.curComplete -= 1
                }
                
                self.cells.remove(at: indexPath.row)
            }
            
            // remove from the workout (realm data)
            let realm = try! Realm()
            try! realm.write {
                self.data.remove(at: indexPath.row)
            }
            
            self.heights.remove(at: indexPath.row)
            self.checkComplete()
            self.reloadData()
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
            cell.delegate = self
            cell.indexPath = indexPath
            cell.updateToggledStatus()
            cell.updateCompleteStatus()
            
            cells.append(cell)
            return cell
        } else {
            cells[indexPath.row].indexPath = indexPath
            return cells[indexPath.row]
        }
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    // MARK: WorkoutSessionTableViewCellDelegate methods
    
    // Height of a cell changed ; update this view's height to match height change
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath) {
        self.heightConstraint?.constant += height - heights[indexPath.row]
        heights[indexPath.row] = height
        
        self.reloadData()
        
        viewDelegate?.heightChange()
    }
    
    // Update complete count, check if we completed all exercises
    func cellCompleteStatusChanged(complete: Bool) {
        curComplete += complete ? 1 : -1
        checkComplete()
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
        
        self.checkComplete()
    }
    
    // Retrieve workouts
    public func getData() -> List<Exercise> {
        return data
    }
    
    // Setup the table view to default properties
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(WorkoutSessionTableViewCell.self,
                      forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
    
    // Check if we completed all exercises
    public func checkComplete() {
        if self.curComplete == self.data.count {
            self.viewDelegate?.updateCompleteStatus(isComplete: true)
        } else {
            self.viewDelegate?.updateCompleteStatus(isComplete: false)
        }
    }
    
    // Saves the workout data
    public func saveWorkoutData() {
        for cell in cells {
            cell.saveWorkoutData()
        }
    }
}

protocol WorkoutSessionTableViewDelegate {
    /*
     The status of the workout is being updated
     */
    func updateCompleteStatus(isComplete: Bool)
    
    /*
     Height of this view changed
     */
    func heightChange()
}
