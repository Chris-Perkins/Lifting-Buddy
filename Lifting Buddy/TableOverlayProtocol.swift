//
//  TableOverlayProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/3/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import Foundation

protocol EmptyTableViewOverlay {
    /*
     * Tells the view we should show the overlay view
     */
    func showViewOverlay()
    
    /*
     * Tells the view we should hide the overlay view
     */
    func hideViewOverlay()
}
