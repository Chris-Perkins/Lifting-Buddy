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
    
    private let data: List<Exercise>
    
    // MARK: View overrides
    
    init(workout: Workout?, exercises: List<Exercise>, style: UITableViewStyle) {
        data = exercises
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView functions
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Initialize our cells..
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WorkoutSessionSummaryTableViewCell
        cell.setExercise(exercise: data[indexPath.row],
                         withDateRecorded: WorkoutSessionView.dateLastInitialized)
        return cell
    }
    
    // Each cell's height is retrieved based on the cell's requirements for progression methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WorkoutSessionSummaryTableViewCell.heightForExercise(exercise: data[indexPath.row])
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
