//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private var historyEntry: ExerciseHistoryEntry?
    
    // MARK: View functions
    
    public func setColor() {
        self.backgroundColor = .red
    }
}
