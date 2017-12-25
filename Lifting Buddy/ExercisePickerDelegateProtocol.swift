//
//  ExercisePickerDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/* A protocol that is called when we select an exercise */

protocol ExercisePickerDelegate {
    /*
     * should be called whenever an exercise is selected from the tableview
     */
    func didSelectExercise(exercise: Exercise)
}
