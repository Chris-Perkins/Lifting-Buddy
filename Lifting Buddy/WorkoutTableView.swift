//
//  WorkoutTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class WorkoutTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: View Properties
    
    // The data displayed in cells
    private var sortedData: [Workout]
    private var data: AnyRealmCollection<Workout>
    // The base height per cell
    public static let baseCellHeight: CGFloat = 50.0
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableViewStyle) {
        let realm = try! Realm()
        self.data = AnyRealmCollection(realm.objects(Workout.self))
        self.sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(style: UITableViewStyle) {
        let realm = try! Realm()
        self.data = AnyRealmCollection(realm.objects(Workout.self))
        self.sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
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
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedData.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! WorkoutTableViewCell
        
        cell.workoutSessionStarter = self.superview as? WorkoutSessionStarter
        cell.showViewDelegate = self.superview as? ShowViewDelegate
        cell.setWorkout(workout: sortedData[indexPath.row])
        cell.updateSelectedStatus()
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let exerCount = CGFloat(sortedData[indexPath.row].getExercises().count)
        
        return self.indexPathForSelectedRow?.row == indexPath.row ?
            WorkoutTableView.baseCellHeight * 2 + exerCount * 30.0 + (exerCount > 0 ? 26 : 0) :
            WorkoutTableView.baseCellHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func refreshData() {
        let realm = try! Realm()
        
        self.data = AnyRealmCollection(realm.objects(Workout.self))
        self.sortedData = Workout.getSortedWorkoutArray(workouts: self.data)
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getSortedData() -> [Workout] {
        return self.sortedData
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
}
