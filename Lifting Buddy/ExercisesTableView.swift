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

class ExercisesTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: View Properties
    
    // A delegate to say when we should overlay
    public var overlayDelegate: TableViewOverlayDelegate?
    // If we're picking an exercise, have a delegate to say what exercise we picked
    public var exercisePickerDelegate: ExercisePickerDelegate?
    
    // Whether or not we're simply selecting an exercise
    private var selectingExercise: Bool
    // The data displayed in cells
    private var sortedData: [Exercise]
    private var data: AnyRealmCollection<Exercise>
    // The base height per cell
    public static let baseCellHeight: CGFloat = 50.0
    
    // MARK: Initializers
    
    init(exercises: AnyRealmCollection<Exercise>, selectingExercise: Bool, frame: CGRect, style: UITableViewStyle) {
        self.data = exercises
        self.sortedData = Exercise.getSortedExerciseArray(exercises: data)
        self.selectingExercise = selectingExercise
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(exercises: AnyRealmCollection<Exercise>, selectingExercise: Bool, style: UITableViewStyle) {
        self.data = exercises
        self.sortedData = Exercise.getSortedExerciseArray(exercises: data)
        self.selectingExercise = selectingExercise
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    override func reloadData() {
        let realm = try! Realm()
        
        self.data = AnyRealmCollection(realm.objects(Exercise.self))
        self.sortedData = Exercise.getSortedExerciseArray(exercises: self.data)
        
        if self.sortedData.count > 0 {
            self.overlayDelegate?.hideViewOverlay()
        } else {
            self.overlayDelegate?.showViewOverlay()
        }
        
        super.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = self.cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        if self.indexPathForSelectedRow == indexPath {
            self.deselectRow(at: indexPath, animated: true)
            self.reloadData()
            cell.updateSelectedStatus()
            
            return nil
        } else {
            var cell2: ExerciseTableViewCell? = nil
            if self.indexPathForSelectedRow != nil {
                cell2 = self.cellForRow(at: self.indexPathForSelectedRow!) as? ExerciseTableViewCell
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
        if self.selectingExercise {
            self.exercisePickerDelegate?.didSelectExercise(exercise: sortedData[indexPath.row])
        }
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedData.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! ExerciseTableViewCell
        cell.mainViewCellDelegate = self.superview as? WorkoutCellDelegate
        cell.showViewDelegate = self.superview as? ShowViewDelegate
        cell.setExercise(exercise: sortedData[indexPath.row])
        cell.setExpandable(expandable: !self.selectingExercise)
        cell.updateSelectedStatus()
        
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let pgmCount = CGFloat(sortedData[indexPath.row].getProgressionMethods().count)
        
        return self.indexPathForSelectedRow?.row == indexPath.row ?
            // The height for when toggled depends on the number of progression methods.
            // If there are no progression methods, no graph and no spacing occurs.
            ExercisesTableView.baseCellHeight * 2 + pgmCount * 40.0 + (pgmCount > 0 ? 320 : 0) :
            ExercisesTableView.baseCellHeight
    }
    
    // MARK: Custom functions
    
    // Retrieve workouts
    public func getSortedData() -> [Exercise] {
        return self.sortedData
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
}
