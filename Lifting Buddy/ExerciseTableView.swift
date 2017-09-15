//
//  SetTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/13/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableView: UITableView, UITableViewDataSource, UITableViewDelegate,
                         ExerciseTableViewCellDelegate {
    
    // MARK: View properties
    
    public var heightConstraint: NSLayoutConstraint?
    public var indexPath: IndexPath?
    public var heightDelegate: ExerciseTableViewDelegate
    
    private var heights: [CGFloat]
    private var totalHeight: CGFloat
    private var exercise: Exercise
    
    // MARK: View inits
    
    init(exercise: Exercise, style: UITableViewStyle, heightDelegate: ExerciseTableViewDelegate) {
        self.exercise = exercise
        self.heights  = [CGFloat]()
        self.heightDelegate = heightDelegate
        totalHeight = 0
        
        super.init(frame: .zero, style: style)
        
        for _ in [0...exercise.getSetCount()] {
            self.createCell()
        }
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UITableViewDataSource Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! ExerciseTableViewCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    // MARK: TableView functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    // MARK: ExerciseTableViewCell Delegate methods
    
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath) {
        heightConstraint?.constant += height - heights[indexPath.row]
        heightDelegate.heightChange(addHeight: height - heights[indexPath.row])
        heights[indexPath.row] = height
    }
    
    func cellCompleteStatusChanged(complete: Bool) {
        // todo: do something
    }
    
    // Private Methods
    
    // Setup the table view to default properties
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
    
    private func createCell() {
        let addHeight = CGFloat(exercise.getProgressionMethods().count) * 50.0
        
        heights.append(addHeight)
        heightConstraint?.constant += addHeight
        heightDelegate.heightChange(addHeight: addHeight)
        self.reloadData()
    }
}

protocol ExerciseTableViewDelegate {
    func heightChange(addHeight: CGFloat)
}
