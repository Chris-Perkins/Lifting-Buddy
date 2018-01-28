//
//  SetTableViewDelegate.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/27/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

protocol SetTableViewDelegate {
    /*
     * Should be called when the number of completed sets changed
     */
    func completedSetCountChanged()
}
