//
//  WorkoutTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var data: [Workout]
    
    // MARK: Initializers
    
    init(workouts: [Workout], frame: CGRect, style: UITableViewStyle) {
        data = workouts
        
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = false
        self.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    // Moved a cell (LPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Modify this code as needed to support more advanced reordering, such as between sections.
        let source = data[sourceIndexPath.row]
        let destination = data[destinationIndexPath.row]
        data[sourceIndexPath.row] = destination
        data[destinationIndexPath.row] = source
    }
    
    // Selected a table view cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(data)
        // TODO: Edit / Delete dialog
        let cell = self.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.niceBlue()
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! WorkoutTableViewCell
        cell.setWorkout(workout: data[indexPath.row])
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Workout) {
        self.frame.size.height += 50
        
        self.data.append(data)
        reloadData()
    }
    
    public func getData() -> [Workout] {
        return data
    }
    
}
