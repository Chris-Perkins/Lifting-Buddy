//
//  SetTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/13/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableView: UITableView, UITableViewDataSource, UITableViewDelegate,
                         ExerciseTableViewCellDelegate {
    
    // MARK: View properties
    
    // The height of this constraint
    public var heightConstraint: NSLayoutConstraint?
    // Index path for this view
    public var indexPath: IndexPath?
    // Delegate that works to change the view's height
    public var heightDelegate: ExerciseTableViewDelegate
    
    // heights per cell. Acts as "data"
    private var heights: [CGFloat]
    // Total height of this tableview
    private var totalHeight: CGFloat
    // Exercise for this tableview
    private var exercise: Exercise
    // Cells in this tableview
    private var cells: [ExerciseTableViewCell] = [ExerciseTableViewCell]()
    
    
    // MARK: View inits
    
    init(exercise: Exercise, style: UITableViewStyle, heightDelegate: ExerciseTableViewDelegate) {
        self.exercise = exercise
        self.heights  = [CGFloat]()
        self.heightDelegate = heightDelegate
        totalHeight = 0
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UITableViewDataSource Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= self.cells.count {
            let cell = ExerciseTableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.setExercise(exercise: self.exercise)
            cell.delegate = self
            cell.indexPath = indexPath
            
            self.cells.append(cell)
            
            return cell
        } else {
            self.cells[indexPath.row].indexPath = indexPath
            self.cells[indexPath.row].layoutIfNeeded()
            return self.cells[indexPath.row]
        }
    }
    
    // MARK: TableView functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.beginUpdates()
            self.deleteRows(at: [indexPath], with: .left)
            self.endUpdates()
            
            self.reloadData()
        }
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        for indexPath in indexPaths {
            self.cells.remove(at: indexPath.row)
            self.cellHeightDidChange(height: 0, indexPath: indexPath)
            self.heights.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: ExerciseTableViewCell Delegate methods
    
    // The cell's height here changed
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath) {
        heightConstraint?.constant += height - heights[indexPath.row]
        heightDelegate.heightChange(addHeight: height - heights[indexPath.row])
        heights[indexPath.row] = height
    }
    
    // This cell has been completed
    func cellCompleteStatusChanged(complete: Bool) {
        // todo: do something
    }
    
    // MARK: Private Methods
    
    // Setup the table view to default properties
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.isScrollEnabled = false
        self.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
    
    // Creates a cell in this tableview
    public func createCell() {
        // + 1 as we incorporate rep count
        let addHeight = CGFloat(exercise.getProgressionMethods().count + 1) * 40.0 + 50
        
        heights.append(addHeight)
        heightConstraint?.constant += addHeight
        heightDelegate.heightChange(addHeight: addHeight)
        
        self.reloadData()
    }
}

protocol ExerciseTableViewDelegate {
    /*
     The height of this workout changed.
     */
    func heightChange(addHeight: CGFloat)
}
