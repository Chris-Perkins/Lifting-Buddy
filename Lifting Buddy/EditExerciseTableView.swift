//
//  ExerciseTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import HPReorderTableView

class EditExerciseTableView: HPReorderTableView, UITableViewDataSource,UITableViewDelegate {
    
    // MARK: View properties
    public var heightConstraint: NSLayoutConstraint?
    
    private var data:[Exercise] = [Exercise].init()
    
    // MARK: Override Init
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        delegate = self
        dataSource = self
        allowsSelection = false
        register(EditExerciseTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TableView Functions
    
    // Moved a cell (HPRTableview requirement for drag-and-drop)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        data.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    // Deletion methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            data.remove(at: indexPath.row)
            
            heightConstraint?.constant -= UITableViewCell.defaultHeight
            reloadData()
        }
    }
    
    // Selected a table view cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(data)
        // TODO: Edit / Delete dialog
        let cell: EditExerciseTableViewCell = cellForRow(at: indexPath) as! EditExerciseTableViewCell
        cell.backgroundColor = .niceBlue
    }
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditExerciseTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath) as! EditExerciseTableViewCell
        cell.setExercise(exercise: data[indexPath.row])
        cell.showViewDelegate = superview as? ShowViewDelegate
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewCell.defaultHeight
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: Exercise) {
        heightConstraint?.constant += UITableViewCell.defaultHeight
        
        self.data.append(data)
        reloadData()
    }
    
    public func getData() -> [Exercise] {
        return data
    }
}
