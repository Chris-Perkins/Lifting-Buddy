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
    
    public var overlayDelegate: EmptyTableViewOverlayDelegate?
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
        if sortedData.count > 0 {
            overlayDelegate?.hideViewOverlay()
        } else {
            overlayDelegate?.showViewOverlay()
        }
        
        return sortedData.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! ExerciseTableViewCell
        cell.workoutStartDelegate = self.superview as? StartWorkoutDelegate
        cell.setExercise(exercise: sortedData[indexPath.row])
        cell.setExpandable(expandable: !self.selectingExercise)
        
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let progressionMethodCount = CGFloat(sortedData[indexPath.row].getProgressionMethods().count)
        
        return self.indexPathForSelectedRow?.row == indexPath.row ?
            ExercisesTableView.baseCellHeight * 2 + progressionMethodCount * 30.0 + (progressionMethodCount > 0 ? 26 : 0) :
            ExercisesTableView.baseCellHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func refreshData() {
        let realm = try! Realm()
        
        self.data = AnyRealmCollection(realm.objects(Exercise.self))
        self.sortedData = Exercise.getSortedExerciseArray(exercises: self.data)
        
        reloadData()
    }
    
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
