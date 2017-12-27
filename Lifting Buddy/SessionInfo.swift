//
//  SessionInfo.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/27/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Holds variables about current session info
 */

// When the session was started
internal var sessionStartDate: Date?
// The workout being activated during the session
internal var sessionWorkout: Workout?
// The exercises that are active during the session
internal var sessionExercises = Set<Exercise>()
