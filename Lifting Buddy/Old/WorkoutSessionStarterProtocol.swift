//
//  WorkoutSessionStarterProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Notifies the sectionview in Lifting Buddy) about session status updates.
 */

import Realm
import RealmSwift

protocol WorkoutSessionStarter {
    /*
     * Notified when a workout is starting
     */
    func startSession(workout: Workout?,
                      exercise: Exercise?)
    /*
     * Notified when a workout is ending
     */
    func endSession(workout withWorkout: Workout?, exercises: List<Exercise>)
    
    /*
     * Notified when the sessionview's mainview changed
     */
    func sessionViewChanged(toView view: UIView)
}
