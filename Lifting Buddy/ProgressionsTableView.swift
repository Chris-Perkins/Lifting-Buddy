//
//  ExerciseTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionsTableView: LPRTableView, UITableViewDataSource,UITableViewDelegate {
    
    // MARK: View properties
    
    private var data:[Exercise] = [Exercise].init()
    var cellHeight: CGFloat = 50.0
    
    // MARK: Override Init
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self
        self.register(ProgressionsTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    // Moved a cell (LPRTableView requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Modify this code as needed to support more advanced reordering, such as between sections.
        let source = data[sourceIndexPath.row]
        let destination = data[destinationIndexPath.row]
        data[sourceIndexPath.row] = destination
        data[destinationIndexPath.row] = source
    }
    
    // Selected a table view cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(data)
        // TODO: Edit / Delete dialog
        let cell: ProgressionsTableViewCell = self.cellForRow(at: indexPath) as! ProgressionsTableViewCell
        cell.backgroundColor = UIColor.niceBlue()
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgressionsTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! ProgressionsTableViewCell
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        self.frame.size.height += cellHeight
        
        self.data.append(data)
        reloadData()
    }
    
    public func getData() -> [Exercise] {
        return data
    }
}
