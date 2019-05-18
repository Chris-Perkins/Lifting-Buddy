//
//  ExerciseHistoryTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import CDAlertView

class ExerciseHistoryTableView: UITableView {
    
    // MARK: View Properties
    
    // A delegate to inform for tableview actions
    public var tableViewDelegate: ExerciseHistoryEntryTableViewDelegate?
    // The tableview should function differently depending on if it's in a session view or not
    public var isInSessionView: Bool {
        // If the superview is a workoutsessiontableviewcell, we know this view is in a session view.
        if let _ = superview as? WorkoutSessionTableViewCell {
            return true
        }
        return false
    }
    
    // holds the progressionmethods for this history piece
    private let progressionMethods: List<ProgressionMethod>
    // holds all the values for data
    private var data: [ExerciseHistoryEntry]
    // a label we use to display if there is no history in it
    private var overlayLabel: UILabel?
    
    // MARK: Static functions
    
    static func heightPerCell(forHistoryEntry historyEntry: ExerciseHistoryEntry) -> CGFloat {
        return ExerciseHistoryTableViewCell.baseHeight +
            CGFloat(historyEntry.exerciseInfo.count) *
            ExerciseHistoryTableViewCell.heightPerProgressionMethod
    }
    
    static func heightPerExercise(forExercise exercise: Exercise) -> CGFloat {
        return ExerciseHistoryTableViewCell.baseHeight +
            CGFloat(exercise.getProgressionMethods().count) *
            ExerciseHistoryTableViewCell.heightPerProgressionMethod
    }
    
    // MARK: Initializers
    
    init(forExercise exercise: Exercise, style: UITableView.Style) {
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
        
        backgroundColor = .primaryBlackWhiteColor
        
        overlayLabel?.setDefaultProperties()
        overlayLabel?.text = NSLocalizedString(isInSessionView ?
                                                "HistoryView.Label.NoSetData":
                                                "HistoryView.Label.NoRecordedData", comment: "")
        overlayLabel?.backgroundColor = .lightestBlackWhiteColor
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: ExerciseHistoryEntry) {
        self.data.insert(data, at: 0)
        
        reloadData()
    }
    
    // Sets the data in reverse order (newest first)
    public func setData(_ data: List<ExerciseHistoryEntry>) {
        self.data.removeAll()
        
        for dataEntry in data.reversed() {
            self.data.append(dataEntry)
        }
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [ExerciseHistoryEntry] {
        return data
    }
    
    public func getTotalHeight() -> CGFloat {
        var totalHeight: CGFloat = 0.0;
        
        for historyEntry in getData() {
            totalHeight += ExerciseHistoryTableView.heightPerCell(forHistoryEntry: historyEntry)
        }
        
        return totalHeight
    }
    
    // Determines whether or not we can modify the data at the given index path
    public func canModifyDataAtIndexPath(_ indexPath: IndexPath) -> Bool {
        // If we're in a session view, we can always modify it.
        // Otherwise, if the entry was entered in a time less than the session start date
        // This prevents the user from modifying the same data in two different places.
        
        // We can never modify it if the exercise was deleted.
        if data[indexPath.row].isInvalidated {
            return false
        }
        else if let sessionStartDate = sessionStartDate {
            return isInSessionView || data[indexPath.row].date!.seconds(from: sessionStartDate) < 0
        } else {
            return true
        }
    }
    
    // Sets up basic table info
    private func setupTableView() {
        delegate = self
        dataSource = self
        allowsSelection = false
        register(ExerciseHistoryTableViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
    }
}


// MARK: TableView Delegate extension

extension ExerciseHistoryTableView: UITableViewDelegate {
    // Each cell's height depends on the number of progression methods, but there is a flat height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ExerciseHistoryTableView.heightPerCell(forHistoryEntry: data[indexPath.row])
    }
    
    // allow cell deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if canModifyDataAtIndexPath(indexPath) {
                let deletionData = data[indexPath.row]
                
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(deletionData)
                }
                
                // Have to remove data beforehand otherwise the cell completestatus doesn't update properly.
                data.remove(at: indexPath.row)
                tableViewDelegate?.dataDeleted(deletedData: deletionData)
                
                reloadData()
            } else {
                let alert = CDAlertView(title: NSLocalizedString("Message.CannotDeleteEntry.Title",
                                                                 comment: ""),
                                        message: NSLocalizedString("Message.CannotDeleteEntry.Desc",
                                                                   comment: ""),
                                        type: CDAlertViewType.error)
                alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.OK", comment: ""),
                                                    font: nil,
                                                    textColor: UIColor.white,
                                                    backgroundColor: UIColor.niceBlue,
                                                    handler: nil))
                alert.show()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.reloadData()
    }
}


// MARK: Data Source extension

extension ExerciseHistoryTableView: UITableViewDataSource {
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExerciseHistoryTableViewCell
        
        // update the label in case of deletion
        if isInSessionView {
            cell.entryNumberLabel.text = "Set #\(data.count - (indexPath.row))"
            cell.isUserInteractionEnabled = true
        } else {
            let dateFormatter = NSDate.getDateFormatter()
            cell.entryNumberLabel.text = dateFormatter.string(from: data[indexPath.row].date!)
            cell.isUserInteractionEnabled = canModifyDataAtIndexPath(indexPath)
        }
        cell.setData(data: data[indexPath.row].exerciseInfo)
        
        return cell
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 && !isInSessionView {
            // We should only display the overlay label if we're not in a session view
            // Done because I don't think it looks nice in the session view.
            if overlayLabel == nil {
                overlayLabel = UILabel()
                overlayLabel?.layer.zPosition = 1001
                
                addSubview(overlayLabel!)
                
                NSLayoutConstraint.clingViewToView(view: overlayLabel!, toView: superview!)
            }
        } else {
            overlayLabel?.removeFromSuperview()
            overlayLabel = nil
        }
        return data.count
    }
}
