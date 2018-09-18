//
//  ProgressionsMethodTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ProgressionsMethodTableView: HPReorderTableView, UITableViewDelegate {
    
    // MARK: View properties
    public var heightConstraint: NSLayoutConstraint?
    
    // the data in this tableview
    private var data: [ProgressionMethod]
    private var cells: [ProgressionMethodTableViewCell]
    
    // MARK: Override Init
    
    override init(frame: CGRect, style: UITableView.Style) {
        data = [ProgressionMethod]()
        cells = [ProgressionMethodTableViewCell]()
        
        super.init(frame: frame, style: style)
        
        delegate = self
        dataSource = self
        allowsSelection = false
        clipsToBounds = true
        register(ProgressionMethodTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: ProgressionMethod) {
        heightConstraint?.constant += UITableViewCell.defaultHeight
        
        self.data.append(data)
        reloadData()
    }
    
    // Returns the data in this tableview
    public func getData() -> [ProgressionMethod] {
        return data
    }
}

extension ProgressionsMethodTableView: UITableViewDataSource {
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell does not exist; create it.
        var cell: ProgressionMethodTableViewCell? = nil
        if cells.count > indexPath.row {
            cell = cells[indexPath.row]
        } else {
            let newCell = ProgressionMethodTableViewCell(style: .default, reuseIdentifier: nil)
            newCell.setProgressionMethod(progressionMethod: data[indexPath.row])
            cells.append(newCell)
            cell = newCell
        }
        
        return cell!
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            data.remove(at: indexPath.row)
            cells.remove(at: indexPath.row)
            
            heightConstraint?.constant -= UITableViewCell.defaultHeight
            reloadData()
        }
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Moved a cell (HPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        data.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        cells.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewCell.defaultHeight
    }
}
