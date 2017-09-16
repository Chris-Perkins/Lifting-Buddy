//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/13/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: ExerciseTableViewCellDelegate?
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.black
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// Functions for delegate (the tableview)
protocol ExerciseTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}
