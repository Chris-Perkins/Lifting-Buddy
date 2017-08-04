//
//  WorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// View which shows all workouts

import UIKit

import RealmSwift
import Realm

class WorkoutView: UIView {
    var workout: Workout?
    
    func setWorkout(workout: Workout?) {
        self.workout = workout
    }
    
    func getWorkout() -> Workout? {
        return self.workout
    }
    
    func showExercises() {
        for exercise in (self.workout?.getExercises())! {
            
        }
    }
}
