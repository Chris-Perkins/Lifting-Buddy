//
//  ExercisesTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/1/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftCharts
import CDAlertView

class ExercisesTableView: UITableView {
    
    // MARK: View Properties
    
    // If we're picking an exercise, have a delegate to say what exercise we picked
    public var exercisePickerDelegate: ExercisePickerDelegate?
    
    // Whether or not we're simply selecting an exercise
    private let selectingExercise: Bool
    // The data displayed in cells
    private var sortedData: [Exercise]
    // the data we sort from
    private var data: AnyRealmCollection<Exercise>
    
    // MARK: Initializers
    
    init(exercises: AnyRealmCollection<Exercise>, selectingExercise: Bool, frame: CGRect,
         style: UITableView.Style) {
        self.selectingExercise = selectingExercise
        
        data = exercises
        sortedData = Exercise.getSortedExerciseArray(exercises: data)
        
        super.init(frame: frame, style: style)
        
        setupTableView()
    }
    
    init(exercises: AnyRealmCollection<Exercise>, selectingExercise: Bool, style: UITableView.Style) {
        self.selectingExercise = selectingExercise
        data = exercises
        sortedData = Exercise.getSortedExerciseArray(exercises: data)
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    // MARK: Custom functions
    
    // Retrieve workouts
    public func getSortedData() -> [Exercise] {
        return sortedData
    }
}

// MARK: TableViewDelegate Functions
extension ExercisesTableView : UITableViewDelegate {
    
    // Reloads data from realm
    override func reloadData() {
        let realm = try! Realm()
        
        data = AnyRealmCollection(realm.objects(Exercise.self))
        sortedData = Exercise.getSortedExerciseArray(exercises: data)
        
        let selectedIndex = indexPathForSelectedRow
        super.reloadData()
        selectRow(at: selectedIndex, animated: true, scrollPosition: .bottom)
    }
    
    // If the cell is selected, it should be expanded if we're not selecting an exercise.
    // Otherwise, give it the default cell height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let pgmCount = CGFloat(sortedData[indexPath.row].getProgressionMethods().count)
        
        return indexPathForSelectedRow?.row == indexPath.row && !selectingExercise ?
            // The height for when toggled depends on the number of progression methods.
            // If there are no progression methods, no graph and no spacing occurs.
            UITableViewCell.defaultHeight + PrettyButton.defaultHeight +
                // + 10 as we add padding to the view.
                (pgmCount > 0 ? ExerciseChartViewWithToggles.getNecessaryHeightForExerciseGraph(
                    exercise: sortedData[indexPath.row]) : 0) + 10  :
            UITableViewCell.defaultHeight
    }
    
    // On select, expand the cell if we're not selecting an exercise
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        if indexPathForSelectedRow == indexPath {
            deselectRow(at: indexPath, animated: true)
            reloadData()
            cell.updateSelectedStatus()
            
            return nil
        } else {
            var cell2: ExerciseTableViewCell? = nil
            if indexPathForSelectedRow != nil {
                cell2 = cellForRow(at: indexPathForSelectedRow!) as? ExerciseTableViewCell
            }
            
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
            reloadData()
            scrollToRow(at: indexPath, at: .none, animated: true)
            
            cell2?.updateSelectedStatus()
            cell.updateSelectedStatus()
            
            return indexPath
        }
    }
    
    // Selected a table view cell; if selectingexercise, return it.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectingExercise {
            exercisePickerDelegate?.didSelectExercise(exercise: sortedData[indexPath.row])
        }
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let exercise = sortedData[indexPath.row]
            
            if !exercise.canModifyCoreProperties {
                let alert = CDAlertView(title: NSLocalizedString("Message.CannotDeleteExercise.Title",
                                                                 comment: ""),
                                        message: NSLocalizedString("Message.CannotDeleteExercise.Desc",
                                                                   comment: ""),
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            } else {
                let alert = CDAlertView(title: NSLocalizedString("Message.DeleteExercise.Title", comment: ""),
                                        message: "All history for '\(exercise.getName()!)' will be deleted.\n" +
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
                                                                                           identifier: exercise.getName(),
                                                                                           value: nil))
                                                        
                                                        exercise.removeProgressionMethods()
                                                        let realm = try! Realm()
                                                        try! realm.write {
                                                            realm.delete(exercise)
                                                        }
                                                        
                                                        self.sortedData.remove(at: indexPath.row)
                                                        self.reloadData()
                                                        return true
                }))
                alert.show()
            }
        }
    }
}

// MARK: UITableViewData source extension
extension ExercisesTableView: UITableViewDataSource {
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedData.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! ExerciseTableViewCell
        cell.mainViewCellDelegate = superview as? WorkoutSessionStarter
        cell.showViewDelegate = superview as? ShowViewDelegate
        cell.setExercise(exercise: sortedData[indexPath.row])
        cell.setExpandable(expandable: !selectingExercise)
        cell.updateSelectedStatus()
        
        return cell
    }
}
