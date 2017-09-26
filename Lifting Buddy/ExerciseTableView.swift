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
    private var identifiers: [String]
    private var totalHeight: CGFloat
    private var exercise: Exercise
    
    private var lastChar: String = ""
    private final let appendStr: String = "ETVC"
    
    private var cells: [ExerciseTableViewCell] = [ExerciseTableViewCell]()
    
    
    // MARK: View inits
    
    init(exercise: Exercise, style: UITableViewStyle, heightDelegate: ExerciseTableViewDelegate) {
        self.exercise = exercise
        identifiers = [String]()
        self.heights  = [CGFloat]()
        self.heightDelegate = heightDelegate
        totalHeight = 0
        
        super.init(frame: .zero, style: style)
        
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
        if indexPath.row >= cells.count {
            let cell = ExerciseTableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.setProgressionMethods(progressionMethods: self.exercise.getProgressionMethods().toArray())
            cell.delegate = self
            cell.indexPath = indexPath
            
            cells.append(cell)
            
            return cell
        } else {
            return cells[indexPath.row]
        }
    }
    
    // MARK: TableView functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.beginUpdates()
            self.deleteRows(at: [indexPath], with: .automatic)
            self.endUpdates()
            
            //self.reloadData()
        }
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        for indexPath in indexPaths {
            self.cells.remove(at: indexPath.row)
            self.cellHeightDidChange(height: 0, indexPath: indexPath)
            self.heights.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
    
    // MARK: Private Methods
    
    private func nextChar(str:String) -> String {
        if let firstChar = str.unicodeScalars.first {
            let nextUnicode = firstChar.value + 1
            if let var4 = UnicodeScalar(nextUnicode) {
                var nextString = ""
                nextString.append(Character(UnicodeScalar(var4)))
                return nextString
            }
        }
        return ""
    }
    
    // Setup the table view to default properties
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.isScrollEnabled = false
        self.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
    
    public func createCell() {
        let addHeight = CGFloat(exercise.getProgressionMethods().count) * 40.0 + 50
        
        heights.append(addHeight)
        heightConstraint?.constant += addHeight
        heightDelegate.heightChange(addHeight: addHeight)
        
        self.backgroundColor = UIColor.black
        self.reloadData()
    }
}

protocol ExerciseTableViewDelegate {
    func heightChange(addHeight: CGFloat)
}
