//
//  TableViewOverlayProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/3/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 A protocol to overlay something on a tableview. Currently unused.
 */

protocol TableViewOverlayDelegate {
    /*
     * Tells the view we should show the overlay view
     */
    func showViewOverlay()
    
    /*
     * Tells the view we should hide the overlay view
     */
    func hideViewOverlay()
}
