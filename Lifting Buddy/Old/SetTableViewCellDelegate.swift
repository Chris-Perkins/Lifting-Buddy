//
//  SetTableViewCellDelegate.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/27/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

protocol SetTableViewCellDelegate {
    /*
     * Informs the delegate that the cell's set completion changed
     */
    func setStatusUpdate(toCompletionStatus completionStatus: Bool)
}
