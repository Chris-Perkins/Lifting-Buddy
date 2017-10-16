//
//  ExerciseHistoryTableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseHistoryTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: View Properties
    
    private var data: [CGFloat]
    public static let baseCellHeight: CGFloat = 50.0
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableViewStyle) {
        self.data = [CGFloat]()
        
        super.init(frame: frame, style: style)
        
        self.setupTableView()
    }
    
    init(workouts: [Workout], style: UITableViewStyle) {
        self.data = [CGFloat]()
        
        super.init(frame: .zero, style: style)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Tableview functions
    
    // Data is what we use to fill in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Create our custom cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell",
                                          for: indexPath as IndexPath)
        cell.textLabel?.text = String(describing: data[indexPath.row])
        return cell
    }
    
    // Each cell has a height of cellHeight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: Custom functions
    
    // Append some data to the tableView
    public func appendDataToTableView(data: CGFloat) {
        self.data.append(data)
        
        reloadData()
    }
    
    // Retrieve workouts
    public func getData() -> [CGFloat] {
        return data
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
    }
}
