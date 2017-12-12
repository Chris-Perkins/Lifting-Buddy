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
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableViewStyle) {
        let realm = try! Realm()
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
        super.init(frame: frame, style: style)
        
        setupTableView()
    }
    
    init(style: UITableViewStyle) {
        let realm = try! Realm()
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = cellForRow(at: indexPath) as! WorkoutTableViewCell
        
        if indexPathForSelectedRow == indexPath {
            deselectRow(at: indexPath, animated: true)
            reloadData()
            cell.updateSelectedStatus()
            
            return nil
        } else {
            var cell2: WorkoutTableViewCell? = nil
            if indexPathForSelectedRow != nil {
                cell2 = cellForRow(at: indexPathForSelectedRow!) as? WorkoutTableViewCell
            }
            
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
            reloadData()
            scrollToRow(at: indexPath, at: .none, animated: true)
            
            cell2?.updateSelectedStatus()
            cell.updateSelectedStatus()
            
            return indexPath
        }
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let workout = sortedData[indexPath.row]
            
            if workout.canModifyCoreProperties {
                let alert = UIAlertController(title: "Delete Workout?",
                                              message: "All history for '" + workout.getName()!
                                                + "' will be deleted.\n" +
                    "This cannot be undone. Continue?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel",
                                              style: .cancel,
                                              handler: nil))
                alert.addAction(
                    UIAlertAction(title: "Delete",
                                  style: .destructive,
                                  handler: { UIAlertAction -> Void in
                                    let realm = try! Realm()
                                    try! realm.write {
                                        realm.delete(workout)
                                    }
                                    
                                    self.sortedData.remove(at: indexPath.row)
                                    self.reloadData()
                    }))
                
                viewController()?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Cannot Delete",
                                              message: "The selected workout cannot be deleted as it is being used in an active workout session.",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok",
                                             style: .default,
                                             handler: nil)
                alert.addAction(okAction)
                
                viewController()?.present(alert, animated: true, completion: nil)

            }
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
        
        cell.workoutSessionStarter = superview as? WorkoutSessionStarter
        cell.showViewDelegate = superview as? ShowViewDelegate
        cell.setWorkout(workout: sortedData[indexPath.row])
        cell.updateSelectedStatus()
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let exerCount = CGFloat(sortedData[indexPath.row].getExercises().count)
        
        return indexPathForSelectedRow?.row == indexPath.row ?
            UITableViewCell.defaultHeight + PrettyButton.defaultHeight + exerCount * 30.0 + (exerCount > 0 ? 26 : 0) :
            UITableViewCell.defaultHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func refreshData() {
        let realm = try! Realm()
        
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getSortedData() -> [Workout] {
        return sortedData
    }
    
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        register(WorkoutTableViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
}
