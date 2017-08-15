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
        self.cellForRow(at: indexPath)?.backgroundColor = UIColor.niceBlue()
        self.data.remove(at: indexPath.row)
        self.deleteRows(at: [indexPath], with: .left)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Custom data cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.white
        cell.textLabel!.text = "\(data[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
