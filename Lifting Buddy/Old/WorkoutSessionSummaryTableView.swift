//
//  WorkoutSummaryTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/22/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutSessionSummaryTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: View properties
    
    // The data for this view
    private let data: List<Exercise>
    // However, we don't want to show multiple of the same exercise.
    // Why? This would cause spaghetti-code if we wanted to show newData vs Old Data nicely.
    // The average user probably shouldn't have the same exercise multiple times in a workout, anyway.
    private var dataWithNoDuplicates: [Exercise]
    
    // MARK: View overrides
    
    init(workout: Workout?, exercises: List<Exercise>, style: UITableView.Style) {
        data = exercises
        dataWithNoDuplicates = [Exercise]()
        
        super.init(frame: .zero, style: style)
        
        // This could be done in O(n), but O(n^2) isn't even slow.
        // We don't display multiple of the same exercise as the
        // summary would look confusing.
        for exercise in exercises {
            if !dataWithNoDuplicates.contains(exercise) {
                dataWithNoDuplicates.append(exercise)
            }
        }
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView functions
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataWithNoDuplicates.count
    }
    
    // Initialize our cells..
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sessionStartDate = sessionStartDate else {
            fatalError("Date session start is nil, but summary view was called!")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WorkoutSessionSummaryTableViewCell
        
        cell.setExercise(exercise: dataWithNoDuplicates[indexPath.row],
                         withDateRecorded: sessionStartDate)
        
        return cell
    }
    
    // Each cell's height is retrieved based on the cell's requirements for progression methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightForExercise = WorkoutSessionSummaryTableViewCell.heightForExercise(exercise: dataWithNoDuplicates[indexPath.row])
        
        return heightForExercise
    }
    
    // MARK: Private functions
    
    // Sets up the tableview with given functions
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        register(WorkoutSessionSummaryTableViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
}
