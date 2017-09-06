//
//  WorkoutTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private var label: UILabel
    private var workout: Workout?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: label,
                                                            belowView: self,
                                                            withPadding: 5).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .left,
                           multiplier: 1,
                           constant: -5).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .right,
                           multiplier: 1,
                           constant: -5).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 5).isActive = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5.0
        label.textAlignment = .center
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    public func setWorkout(workout: Workout) {
        self.workout = workout
        
        label.text = workout.getName()
        label.textColor = UIColor.niceBlue()
    }
    
    public func getWorkout() -> Workout? {
        return self.workout
    }
}
