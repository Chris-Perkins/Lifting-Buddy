//
//  WorkoutStartTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private var data: [Exercise]
    public static let baseCellHeight: CGFloat = 50.0
    
    // MARK: Initializers
    
    init(workout: Workout, frame: CGRect, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workout: Workout, style: UITableViewStyle) {
        data = workout.getExercises().toArray()
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = self.cellForRow(at: indexPath) as! WorkoutTableViewCell
        
        if self.indexPathForSelectedRow == indexPath {
            self.deselectRow(at: indexPath, animated: true)
            self.reloadData()
            cell.updateSelectedStatus()
            
            return nil
        } else {
            var cell2: WorkoutTableViewCell? = nil
            if self.indexPathForSelectedRow != nil {
                cell2 = self.cellForRow(at: self.indexPathForSelectedRow!) as? WorkoutTableViewCell
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
        
            cell.setExercise(exercise: data[indexPath.row])
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        self.data.append(data)
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [Exercise] {
        return data
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(WorkoutStartTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }

}
