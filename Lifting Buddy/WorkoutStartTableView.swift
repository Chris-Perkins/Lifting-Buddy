//
//  WorkoutStartTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutStartTableView: UITableView, UITableViewDelegate, UITableViewDataSource,
                             WorkoutStartTableViewCellDelegate {
    
    // MARK: View properties
    
    // Base cell height for each tableviewcell
    public static let baseCellHeight: CGFloat = 50.0
    
    // Height constraint for this view
    public var heightConstraint: NSLayoutConstraint?
    // The delegate for this view
    public var viewDelegate: WorkoutStartTableViewDelegate?
    
    // Data, holds exercises per cell
    private var data: List<Exercise>
    // cells in this tableview
    public var cells: [WorkoutStartTableViewCell]
    // Heights per cell
    private var heights: [CGFloat]
    // Whether or not this workout is complete
    private var curComplete: Int
    // The currently toggled cell
    private var curToggledCell: WorkoutStartTableViewCell?
    
    // MARK: Initializers
    
    init(workout: Workout?, frame: CGRect, style: UITableViewStyle) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutStartTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(WorkoutStartTableView.baseCellHeight)
        }
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workout: Workout?, style: UITableViewStyle) {
        data = workout?.getExercises() ?? List<Exercise>()
        cells = [WorkoutStartTableViewCell]()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(WorkoutStartTableView.baseCellHeight)
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
    
    // Moved a cell (LPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Modify this code as needed to support more advanced reordering, such as between sections.
        let sourceData = data[sourceIndexPath.row]
        let destinationData = data[destinationIndexPath.row]
        data[sourceIndexPath.row] = destinationData
        data[destinationIndexPath.row] = sourceData
        
        let sourceCell = cells[sourceIndexPath.row]
        let destinationCell = cells[destinationIndexPath.row]
        cells[sourceIndexPath.row] = destinationCell
        cells[destinationIndexPath.row] = sourceCell
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= cells.count {
            let cell =
                WorkoutStartTableViewCell(exercise: data[indexPath.row],
                                          style: .default,
                                          reuseIdentifier: nil)
            cell.delegate = self
            cell.indexPath = indexPath
            
            cells.append(cell)
            return cell
        } else {
            return cells[indexPath.row]
        }
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    // MARK: WorkoutStartTableViewCellDelegate methods
    
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
    
    // A cell was toggled
    func  cellToggled(indexPath: IndexPath) {
        if curToggledCell?.indexPath != indexPath {
            curToggledCell?.setIsToggled(toggled: false)
            curToggledCell = cellForRow(at: indexPath) as? WorkoutStartTableViewCell
        }
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        heights.append(WorkoutStartTableView.baseCellHeight)
        
        self.data.append(data)
        reloadData()
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
        self.register(WorkoutStartTableViewCell.self, forCellReuseIdentifier: "cell")
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

protocol WorkoutStartTableViewDelegate {
    /*
     The status of the workout is being updated
     */
    func updateCompleteStatus(isComplete: Bool)
    
    /*
     Height of this view changed
     */
    func heightChange()
}
