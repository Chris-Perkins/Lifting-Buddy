//
//  ExerciseTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var data = ["1", "2", "3"]
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Edit / Delete dialog
        let cell: ExerciseTableViewCell = self.cellForRow(at: indexPath) as! ExerciseTableViewCell
        cell.backgroundColor = UIColor.niceBlue()
        if cell.getType() == ExerciseTableViewCell.CellTypes.ADD {
            // Todo: new exercise creation here
            print("create exercise")
        } else {
            self.data.remove(at: indexPath.row)
            self.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ExerciseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath as IndexPath) as! ExerciseTableViewCell
        if indexPath.row + 1 == data.count {
            cell.setType(type: .ADD)
        } else {
            cell.setType(type: .EXERCISE)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
