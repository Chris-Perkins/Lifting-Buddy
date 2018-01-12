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
import CDAlertView

class WorkoutTableView: UITableView {
    
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
    
    override func reloadData() {
        let realm = try! Realm()
        
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutArray(workouts: data)
        
        var selectedWorkout: Workout?
        if let selectedIndex = indexPathForSelectedRow {
            selectedWorkout = sortedData[selectedIndex.row]
        }
        super.reloadData()
        if let selectedWorkout = selectedWorkout, let indexOfWorkout = sortedData.index(of: selectedWorkout) {
            selectRow(at: IndexPath(row: indexOfWorkout, section: 0), animated: true, scrollPosition: .bottom)
        }
    }
    
    // MARK: Custom functions
    
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

extension WorkoutTableView: UITableViewDataSource {
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedData.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! WorkoutTableViewCell
        
        cell.showViewDelegate = superview as? ShowViewDelegate
        cell.exerciseDisplayer = superview as? ExerciseDisplayer
        cell.setWorkout(workout: sortedData[indexPath.row])
        cell.updateSelectedStatus()
        return cell
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let workout = sortedData[indexPath.row]
            
            if workout.canModifyCoreProperties {
                let alert = CDAlertView(title: NSLocalizedString("Message.DeleteWorkout.Title", comment: ""),
                                        message: "All history for '\(workout.getName()!)' will be deleted.\n" +
                    "This action cannot be undone.",
                                        type: CDAlertViewType.warning)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Cancel", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Delete", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceRed,
                                                    handler: { (CDAlertViewAction) in
                                                        let realm = try! Realm()
                                                        try! realm.write {
                                                            realm.delete(workout)
                                                        }
                                                        
                                                        self.sortedData.remove(at: indexPath.row)
                                                        self.reloadData()
                }))
                alert.show()
            } else {
                let alert = CDAlertView(title: NSLocalizedString("Message.CannotDeleteWorkout.Title",
                                                                 comment: ""),
                                        message: NSLocalizedString("Message.CannotDeleteWorkout.Desc",
                                                                   comment: ""),
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            }
        }
    }
}

extension WorkoutTableView: UITableViewDelegate {
    // Expand this cell, un-expand the other cell
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
    
    // Each cell's height depends on whether or not it has been selected
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let exerCount = CGFloat(sortedData[indexPath.row].getExercises().count)
        
        return indexPathForSelectedRow?.row == indexPath.row ?
            UITableViewCell.defaultHeight + PrettyButton.defaultHeight + exerCount * WorkoutTableViewCell.heightPerExercise + WorkoutTableViewCell.heightPerLabel :
            UITableViewCell.defaultHeight
    }
}
