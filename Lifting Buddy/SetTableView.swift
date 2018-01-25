//
//  SetTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift

class SetTableView: UITableView {
    
    // MARK: View properties
    
    public static let heightPerProgressionMethodInput: CGFloat = 40.0
    
    private var exercise: Exercise
    private var data: [ExerciseHistoryEntry]
    
    // MARK: View inits
    
    init(forExercise exercise: Exercise) {
        self.exercise = exercise
        data          = [ExerciseHistoryEntry]()
        
        super.init(frame: .zero, style: .plain)
        
        for _ in 0..<exercise.getSetCount() {
            data.append(ExerciseHistoryEntry())
        }
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View functions
    
    public static func getHeightPerCell(forExercise exercise: Exercise) -> CGFloat {
        let pgmHeights = CGFloat(exercise.getProgressionMethods().count) *
                            heightPerProgressionMethodInput
        let baseHeight = UITableViewCell.defaultHeight
        
        return pgmHeights + baseHeight
    }
    
    // Gets the height for this view
    public func getHeight() -> CGFloat {
        return CGFloat(data.count) *
                    SetTableView.getHeightPerCell(forExercise: exercise)
    }
    
    // Gets the data for this tableview
    public func getData() -> [ExerciseHistoryEntry] {
        return data
    }
    
    // Applies basic tableview properties
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = true
        backgroundColor = .clear
        register(SetTableViewCell.self, forCellReuseIdentifier: "cell")
    }
}


// MARK: TableViewDelegate Extension

extension SetTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fatalError("Please delete")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


// MARK: Data Source Extension

extension SetTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "cell") as! SetTableViewCell
        
        cell.setColor()
        
        return cell
    }
    
    
}
