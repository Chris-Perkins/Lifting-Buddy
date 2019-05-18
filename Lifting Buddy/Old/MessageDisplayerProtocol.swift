//
//  ShowMessageProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/7/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

@objc protocol MessageDisplayer {
    /*
     * Tells the delegate to display a message
     */
    func displayMessage(_ message: Message)
    
    /*
     * Tells the delegate we're going to start displaying messages
     */
    @objc optional func messageQueueStarted()
    
    /*
     * Tells the delegate we're done displaying messages
     */
    @objc optional func messageQueueEnded()
}
