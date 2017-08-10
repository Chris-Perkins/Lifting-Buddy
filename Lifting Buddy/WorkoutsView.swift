//
//  WorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// View which shows information about a workout

import UIKit

import RealmSwift
import Realm

class WorkoutsView: UIView {
    var workout: Workout?
    
    override func layoutSubviews() {
        let floatyButton: PrettyButton = PrettyButton(frame: CGRect(x: self.frame.maxX - 100,
                                                                    y: self.frame.maxY - 100,
                                                                    width: 75,
                                                                    height: 75))
        floatyButton.backgroundColor = UIColor.niceBlue()
        floatyButton.setOverlayStyle(style: .BLOOM)
        floatyButton.cornerRadius = floatyButton.frame.width / 2
        floatyButton.shadowOpacity = 0.5
        
        self.addSubview(floatyButton)
        
        super.layoutSubviews()
    }
    
    func setWorkout(workout: Workout?) {
        self.workout = workout
    }
    
    func getWorkout() -> Workout? {
        return self.workout
    }
    
    func showExercises() {
        /*for exercise in (self.workout?.getExercises())! {
            
        }*/
    }
}
