//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionsTableViewCell: UITableViewCell {
    
    // View properties
    public var label: UILabel = UILabel.init()
    
    // View overrides
    
    override func layoutSubviews() {
        // Stroke with our nice blue
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5.0
        
        label.frame = CGRect(x: 5,
                             y: 5,
                             width: self.frame.width - 10,
                             height: self.frame.height - 10)
        label.textColor = UIColor.niceBlue()
        self.addSubview(label)
    }
}
