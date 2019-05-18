//
//  ExerciseDisplayerProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Helps notifying that an exercise should be displayed.
 Currently used to pass data from the workout tab to the section view.
 */

protocol ExerciseDisplayer {
    /*
     * Tells our view to display an exercise
     */
    func displayExercise(_ exercise: Exercise)
}
