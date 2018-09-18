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
    public var sessionStartDate = Date()
    
    public var completedSetCountDelegate: SetTableViewDelegate?
    public var cellDeletionDelegate: CellDeletionDelegate?
    
    public var completedSetCount: Int {
        didSet {
            completedSetCountDelegate?.completedSetCountChanged()
        }
    }
    
    private var exercise: Exercise
    private var data: [ExerciseHistoryEntry]
    private var cells: [SetTableViewCell]
    
    // MARK: View inits
    
    init(forExercise exercise: Exercise) {
        self.exercise     = exercise
        completedSetCount = 0
        data              = [ExerciseHistoryEntry]()
        cells             = [SetTableViewCell]()
        
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
    
    // Gets the height for this view
    public func getHeight() -> CGFloat {
        return CGFloat(data.count) *
                    SetTableViewCell.getHeight(forExercise: exercise)
    }
    
    // Gets the data for this tableview
    public func getData() -> [ExerciseHistoryEntry] {
        return data
    }
    
    public func appendDataPiece(_ dataPiece: ExerciseHistoryEntry) {
        data.append(dataPiece)
        reloadData()
    }
    
    // Applies basic tableview properties
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = false
        backgroundColor = .clear
        register(SetTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
    }
}


// MARK: TableViewDelegate Extension

extension SetTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // We simply need to remove the completed set count from this cell.
            // This prevents a bug by having additional cell completed counts
            // If the cell was deleted.
            let cell = cellForRow(at: indexPath) as! SetTableViewCell
            
            if cell.completeButton.isToggled {
                completedSetCount -= 1
            }
            
            data.remove(at: indexPath.row)
            if indexPath.row < cells.count {
                cells.remove(at: indexPath.row)
            }
            
            cellDeletionDelegate?.deleteData(at: indexPath.row)
            
            reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SetTableViewCell.getHeight(forExercise: exercise)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


// MARK: DataSource Extension

extension SetTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SetTableViewCell?
        
        if indexPath.row < cells.count {
            cell = cells[indexPath.row]
        } else {
            cell = SetTableViewCell(style: .default, reuseIdentifier: nil)
            
            cell?.exercise       = exercise
            cell?.historyEntry   = data[indexPath.row]
            cell?.statusDelegate = self
            
            // Subtract default height so the title height is not included
            cell?.inputViewHeightConstraint?.constant =
                SetTableViewCell.getHeight(forExercise: exercise) - UITableViewCell.defaultHeight
            
            cells.append(cell!)
        }
        
        guard let setCell = cell else {
            fatalError("Cell does not exist, but it should?")
        }
        
        setCell.titleLabel.text = "\tSet #\(indexPath.row + 1)"
        // This is done to store the session sets in order.
        // Yes, it's a hacky fix.
        // However, I could not think of a better way to design this
        setCell.setDate = sessionStartDate.addingTimeInterval(Double(indexPath.row))
        
        return setCell
    }  
}


// MARK: SetTableViewCellDelegate Extension

extension SetTableView: SetTableViewCellDelegate {
    func setStatusUpdate(toCompletionStatus completionStatus: Bool) {
        completedSetCount += completionStatus ? 1 :  -1
        
        for cell in visibleCells {
            cell.layoutSubviews()
        }
    }
}
