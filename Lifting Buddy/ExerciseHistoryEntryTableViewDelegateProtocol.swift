//
//  ExerciseHistoryEntryTableViewDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Used to notify a exercisehistoryentrytableview that a cell was deleted
 */

protocol ExerciseHistoryEntryTableViewDelegate {
    /*
     * Inform when a cell is deleted
     */
    func dataDeleted(deletedData: ExerciseHistoryEntry)
}
