//
//  CreateExerciseViewDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Informs the calling view that an exercise was successfully saved
 */

protocol CreateExerciseViewDelegate {
    // Pass exercise result from this screen to the delegate
    func finishedWithExercise(exercise: Exercise)
}
