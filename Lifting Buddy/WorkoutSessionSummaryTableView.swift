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
    
    let data: List<Exercise>
    let dateInitialized: Date
    
    // MARK: View overrides
    
    init(workout: Workout?, exercises: List<Exercise>, style: UITableViewStyle) {
        self.data = exercises
        self.dateInitialized = Date.init(timeIntervalSinceNow: 0)
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
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
                         withDateRecorded: self.dateInitialized)
        return cell
    }
    
    // Each cell's height is retrieved based on the cell's requirements for progression methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WorkoutSessionSummaryTableViewCell.heightForExercise(exercise: data[indexPath.row])
    }
    
    // MARK: Private functions
    
    // Sets up the tableview with given functions
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(WorkoutSessionSummaryTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
}
