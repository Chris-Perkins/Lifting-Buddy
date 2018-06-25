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
    private var sortedData: [(String, [Workout])]
    private var data: AnyRealmCollection<Workout>
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableViewStyle) {
        let realm = try! Realm()
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutsSeparatedByDays(workouts: data)
        
        super.init(frame: frame, style: style)
        
        setupTableView()
    }
    
    init(style: UITableViewStyle) {
        let realm = try! Realm()
        data = AnyRealmCollection(realm.objects(Workout.self))
        sortedData = Workout.getSortedWorkoutsSeparatedByDays(workouts: data)
        
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
        sortedData = Workout.getSortedWorkoutsSeparatedByDays(workouts: data)
        
        super.reloadData()
    }
    
    // MARK: Custom functions
    
    // Retrieve workouts
    public func getSortedData() -> [(String, [Workout])] {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedData.count
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedData[section].1.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! WorkoutTableViewCell
        
        cell.showViewDelegate = superview as? ShowViewDelegate
        cell.setWorkout(workout: sortedData[indexPath.section].1[indexPath.row])
        cell.updateSelectedStatus()
        
        // IndexPath of 0 denotes that this workout is today
        cell.workoutRequiresAttention = indexPath.section == 0
        return cell
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let workout = sortedData[indexPath.section].1[indexPath.row]
            
            if workout.canModifyCoreProperties {
                let alert = CDAlertView(title: NSLocalizedString("Message.DeleteWorkout.Title", comment: ""),
                                        message: "This will delete all records of '\(workout.getName()!)', and this includes its occurrences on other days.n" +
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
                                                        MessageQueue.shared.append(Message(type: .objectDeleted,
                                                                                           identifier: workout.getName(),
                                                                                           value: nil))
                                                        
                                                        let realm = try! Realm()
                                                        try! realm.write {
                                                            realm.delete(workout)
                                                        }
                                                        
                                                        self.reloadData()
                                                        
                                                        return true
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundView?.backgroundColor = UIColor.lightBlackWhiteColor
            headerView.textLabel?.textColor = UILabel.titleLabelTextColor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sortedData[section].1.isEmpty ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedData[section].0
    }
    
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
        let exerCount = CGFloat(sortedData[indexPath.section].1[indexPath.row].getExercises().count)
        
        return indexPathForSelectedRow?.elementsEqual(indexPath) ?? false ?
            UITableViewCell.defaultHeight + PrettyButton.defaultHeight + exerCount * WorkoutTableViewCell.heightPerExercise + WorkoutTableViewCell.heightPerLabel :
            UITableViewCell.defaultHeight
    }
}
