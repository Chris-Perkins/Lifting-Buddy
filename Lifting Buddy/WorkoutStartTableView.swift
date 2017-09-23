//
//  WorkoutStartTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableView: UITableView, UITableViewDelegate, UITableViewDataSource,
                             WorkoutStartTableViewCellDelegate {
    
    // MARK: View properties
    
    public static let baseCellHeight: CGFloat = 50.0
    
    public var heightConstraint: NSLayoutConstraint?
    public var viewDelegate: WorkoutStartTableViewDelegate?
    
    private var data: [Exercise]
    private var setExercise: [Bool]
    private var heights: [CGFloat]
    private var curComplete: Int
    private var curToggledCell: WorkoutStartTableViewCell?
    
    // MARK: Initializers
    
    init(workout: Workout, frame: CGRect, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
        heights = [CGFloat]()
        setExercise = [Bool]()
        curComplete = 0
        
        for _ in data {
            heights.append(WorkoutStartTableView.baseCellHeight)
            setExercise.append(false)
        }
        self.heightConstraint?.constant = heights.reduce(0, +)
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workout: Workout, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
        heights = [CGFloat]()
        setExercise = [Bool]()
        curComplete = 0
        
        for _ in data {
            heights.append(WorkoutStartTableView.baseCellHeight)
            setExercise.append(false)
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
        if !setExercise[indexPath.row] {
            cell.delegate = self
            cell.indexPath = indexPath
            cell.setExercise(exercise: data[indexPath.row])
            
            setExercise[indexPath.row] = true
        }
        return cell
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
    
    func heightChange()
}
