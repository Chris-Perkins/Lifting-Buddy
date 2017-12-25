//
//  WorkoutSessionTableViewDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Cell-to-tableview status updates are performed in this 
 */

protocol WorkoutSessionTableViewDelegate {
    /*
     The status of the workout is being updated
     */
    func updateCompleteStatus(isComplete: Bool)
    
    /*
     Height of this view changed
     */
    func heightChange()
}

