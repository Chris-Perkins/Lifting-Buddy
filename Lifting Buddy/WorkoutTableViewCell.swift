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
    
    private var workout: Workout?
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5.0
    }
    
    // MARK: Encapsulated methods
    
    public func setWorkout(workout: Workout) {
        self.workout = workout
    }
    
    public func getWorkout() -> Workout? {
        return self.workout
    }
}
