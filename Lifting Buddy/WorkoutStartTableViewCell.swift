//
//  WorkoutStartTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableViewCell: UITableViewCell {
    private var exercise: Exercise?
    
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
    }
}
