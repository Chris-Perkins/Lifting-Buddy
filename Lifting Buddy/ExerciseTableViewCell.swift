//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // View properties
    
    private var innerView: UIView?
    private var strokeWidth: CGFloat = 1.0
    public var label: UILabel = UILabel.init()
    
    // View overrides
    
    override func layoutSubviews() {
        // Stroke with our nice blue
        self.backgroundColor = UIColor.niceBlue()
        self.layer.cornerRadius = 5.0
        
        innerView = UIView(frame: CGRect(x: strokeWidth,
                                         y: strokeWidth,
                                         width: self.frame.width - 2 * strokeWidth,
                                         height: self.frame.height - 2 * strokeWidth))
        innerView?.layer.cornerRadius = 5.0
        innerView?.backgroundColor = UIColor.white
        self.addSubview(innerView!)
        
        label.frame = CGRect(x: 5, y: 5, width: innerView!.frame.width - 10, height: innerView!.frame.height - 10)
        label.textColor = UIColor.niceBlue()
        innerView?.addSubview(label)
    }
}
