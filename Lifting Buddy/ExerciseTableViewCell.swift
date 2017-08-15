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
    
    public enum CellTypes {
        case ADD
        case EXERCISE
    }
    
    private var innerView: UIView?
    private var strokeWidth: CGFloat = 1.0
    private var type: CellTypes?
    
    
    // View overrides
    
    override func layoutSubviews() {
        // Stroke with our nice blue
        self.backgroundColor = UIColor.niceBlue()
        self.layer.cornerRadius = 5.0
        
        innerView = UIView(frame: CGRect(x: strokeWidth,
                                         y: strokeWidth,
                                         width: self.frame.width - 2 * strokeWidth,
                                         height: self.frame.height - 2 * strokeWidth))
        innerView?.backgroundColor = UIColor.white
        innerView?.layer.cornerRadius = 5.0
        self.addSubview(innerView!)
    }
    
    public func setType(type: CellTypes) {
        self.type = type
    }
    
    public func getType() -> CellTypes? {
        return self.type
    }
}
