//
//  ProgressionsMethodTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionsMethodTableView: UITableView, UITableViewDataSource,UITableViewDelegate {
    
    // MARK: View properties
    public var heightConstraint: NSLayoutConstraint?
    
    // the data in this tableview
    private var data:[ProgressionMethod] = [ProgressionMethod].init()
    // the cells in this tableview
    private var cells: [ProgressionMethodTableViewCell] = [ProgressionMethodTableViewCell]()
    // the height per cell
    public static let cellHeight: CGFloat = 50.0
    
    // MARK: Override Init
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = false
        self.clipsToBounds = true
        self.register(ProgressionMethodTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    // Moved a cell (LPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Modify this code as needed to support more advanced reordering, such as between sections.
        let sourceData = data[sourceIndexPath.row]
        let destinationData = data[destinationIndexPath.row]
        data[sourceIndexPath.row] = destinationData
        data[destinationIndexPath.row] = sourceData
        
        let sourceCell = cells[sourceIndexPath.row]
        let destinationCell = cells[destinationIndexPath.row]
        cells[sourceIndexPath.row] = destinationCell
        cells[destinationIndexPath.row] = sourceCell
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.data.remove(at: indexPath.row)
            self.cells.remove(at: indexPath.row)
            
            heightConstraint?.constant -= 50
            self.reloadData()
        }
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell does not exist; create it.
        if indexPath.row >= cells.count {
            let cell = ProgressionMethodTableViewCell(style: .default, reuseIdentifier: nil)
            cells.append(cell)
        }
        
        return cells[indexPath.row]
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ProgressionsMethodTableView.cellHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: ProgressionMethod) {
        heightConstraint?.constant += 50
        
        self.data.append(data)
        reloadData()
    }
    
    // Returns the data in this tableview
    public func getData() -> [ProgressionMethod] {
        return data
    }
}
