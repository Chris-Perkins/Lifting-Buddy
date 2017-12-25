//
//  WorkoutSessionTableViewCellDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Notifies the tableview that cell height has changed or that a cell was 
 */

protocol WorkoutSessionTableViewCellDelegate {
    /*
     * This cell height changed
     */
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    /*
     * This cell's completion status changed
     */
    func cellCompleteStatusChanged(complete: Bool)
}
