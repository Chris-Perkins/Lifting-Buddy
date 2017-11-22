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
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.data.remove(at: indexPath.row)
            
            heightConstraint?.constant -= UITableViewCell.defaultHeight
            self.reloadData()
        }
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell does not exist; create it.
        let cell = self.dequeueReusableCell(withIdentifier: "cell") as! ProgressionMethodTableViewCell
        cell.setProgressionMethod(progressionMethod: data[indexPath.row])
        
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewCell.defaultHeight
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
