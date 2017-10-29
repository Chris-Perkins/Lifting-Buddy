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
    
    // holds the progressionmethods for this history piece
    private let progressionMethods: List<ProgressionMethod>
    // holds all the values for data
    private var data: [[String]]
    // holds all cells for the table
    private var cells: [ExerciseHistoryTableViewCell] = [ExerciseHistoryTableViewCell]()
    
    // MARK: Initializers
    
    init(forExercise: Exercise, style: UITableViewStyle) {
        self.progressionMethods = forExercise.getProgressionMethods()
        self.data = [[String]]()
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Encapsulated methods
    
    // returns all the cells from this table
    public func getCells() -> [ExerciseHistoryTableViewCell] {
        return self.cells
    }
    
    // MARK: Tableview functions
    
    // allow cell deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            self.data.remove(at: indexPath.row)
            self.cells.remove(at: indexPath.row)
            self.reloadData()
        }
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if the row does not have data yet, create it
        if indexPath.row >= cells.count {
            var dataToSend = [(ProgressionMethod, String)]()
            
            // The first progressionMethod will always be reps.
            for (index, dataPiece) in data[indexPath.row].enumerated() {
                dataToSend.append((progressionMethods[index],
                                   dataPiece))
            }
            
            let cell = ExerciseHistoryTableViewCell(data: dataToSend,
                                                    style: .default,
                                                    reuseIdentifier: nil)
            cells.append(cell)
            
            // update the label in case of deletion
            cell.setLabel.text = "Set #" + String(indexPath.row + 1)
            
            return cell
        } else {
            // otherwise, we can simply return it
            
            // update the label in case of deletion
            cells[indexPath.row].setLabel.text = "Set #" + String(indexPath.row + 1)
            return cells[indexPath.row]
        }
    }
    
    // Each cell's height depends on the number of progression methods, but there is a flat height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ExerciseHistoryTableViewCell.baseHeight +
                CGFloat(self.progressionMethods.count) *
                ExerciseHistoryTableViewCell.heightPerProgressionMethod
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: [String]) {
        self.data.append(data)
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [[String]] {
        return data
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(ExerciseHistoryTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
}
