//
//  PrettySegmentedControlProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 Notifies the delegate whenever a segment selection was changed
 */

import Foundation

protocol PrettySegmentedControlDelegate {
    /*
     Should be called whenever the index of selection changed.
     */
    func segmentSelectionChanged(index: Int)
}
