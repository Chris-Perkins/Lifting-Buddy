//
//  ExerciseHistoryTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift

class ExerciseHistoryTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: View Properties
    
    // A delegate to inform for tableview actions
    public var tableViewDelegate: TableViewDelegate?
    
    // holds the progressionmethods for this history piece
    private let progressionMethods: List<ProgressionMethod>
    // holds all the values for data
    private var data: [ExerciseHistoryEntry]
    
    // MARK: Initializers
    
    init(forExercise exercise: Exercise, style: UITableViewStyle) {
        progressionMethods = exercise.getProgressionMethods()
        data = [ExerciseHistoryEntry]()
        
        super.init(frame: .zero, style: style)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .white
    }
    
    // MARK: Tableview functions
    
    // allow cell deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableViewDelegate?.dataDeleted(deletedData: data[indexPath.row])
            data.remove(at: indexPath.row)
            reloadData()
        }
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dataToSend = [(ProgressionMethod, String)]()
        
        // The first progressionMethod will always be reps.
        for (index, dataPiece) in data[indexPath.row].exerciseInfo.enumerated() {
            dataToSend.append((progressionMethods[index],
                               dataPiece.value!))
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExerciseHistoryTableViewCell
        
        // update the label in case of deletion
        cell.setLabel.text = "Set #" + String(indexPath.row + 1)
        cell.setData(data: dataToSend)
        
        return cell
    }
    
    // Each cell's height depends on the number of progression methods, but there is a flat height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ExerciseHistoryTableViewCell.baseHeight +
            CGFloat(progressionMethods.count) *
            ExerciseHistoryTableViewCell.heightPerProgressionMethod
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: ExerciseHistoryEntry) {
        
        self.data.append(data)
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [ExerciseHistoryEntry] {
        return data
    }
    
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        register(ExerciseHistoryTableViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
}

protocol TableViewDelegate {
    /*
     * Inform when a cell is deleted
     */
    func dataDeleted(deletedData: ExerciseHistoryEntry)
}
