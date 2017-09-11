//
//  WorkoutStartTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableView: UITableView, UITableViewDelegate, UITableViewDataSource, WorkoutStartTableViewCellDelegate {
    
    // MARK: View properties
    
    public static let baseCellHeight: CGFloat = 50.0
    
    public var heightConstraint: NSLayoutConstraint?
    public var viewDelegate: WorkoutStartTableViewDelegate?
    
    private var data: [Exercise]
    private var heights: [CGFloat]
    private var curComplete: Int
    
    // MARK: Initializers
    
    init(workout: Workout, frame: CGRect, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
        heights = [CGFloat]()
        curComplete = 0
        
        for _ in data {
            heights.append(WorkoutStartTableView.baseCellHeight)
        }
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workout: Workout, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
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
        self.layer.cornerRadius = 5.0
    }
    
    // MARK: TableView Functions
    
    override func reloadData() {
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = self.cellForRow(at: indexPath) as! WorkoutStartTableViewCell
        
        if self.indexPathForSelectedRow == indexPath {
            self.deselectRow(at: indexPath, animated: true)
            self.reloadData()
            cell.updateSelectedStatus()
            
            return nil
        } else {
            var cell2: WorkoutStartTableViewCell? = nil
            if self.indexPathForSelectedRow != nil {
                cell2 = self.cellForRow(at: self.indexPathForSelectedRow!) as? WorkoutStartTableViewCell
            }
            
            self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.reloadData()
            self.scrollToRow(at: indexPath, at: .none, animated: true)
            
            cell2?.updateSelectedStatus()
            cell.updateSelectedStatus()
            
            return indexPath
        }
    }
    
    // Selected a table view cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // Moved a cell (LPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Modify this code as needed to support more advanced reordering, such as between sections.
        let source = data[sourceIndexPath.row]
        let destination = data[destinationIndexPath.row]
        data[sourceIndexPath.row] = destination
        data[destinationIndexPath.row] = source
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! WorkoutStartTableViewCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setExercise(exercise: data[indexPath.row])
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    // MARK: WorkoutStartTableViewCellDelegate methods
    
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath) {
        self.heightConstraint?.constant += height - heights[indexPath.row]
        heights[indexPath.row] = height
        
        self.reloadData()
    }
    
    // Update complete count, check if we completed all exercises
    func cellCompleteStatusChanged(complete: Bool) {
        curComplete += complete ? 1 : -1
        checkComplete()
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        heights.append(WorkoutStartTableView.baseCellHeight)
        
        self.data.append(data)
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [Exercise] {
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
}

protocol WorkoutStartTableViewDelegate {
    func updateCompleteStatus(isComplete: Bool)
}
