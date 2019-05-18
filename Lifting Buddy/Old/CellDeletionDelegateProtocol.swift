//
//  CellDeletionDelegateProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Should be called whenever we want to delete data from a cell.
 */

protocol CellDeletionDelegate {
    /*
     * The callee should delete the data at the given index
     */
    func deleteData(at index: Int)
}
