//
//  InputViewProtocol.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/17/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/*
 An input view for use in polymorphism; that's it.
 Has to allow returning of input views that are BetterInputViews
 */

import Foundation

protocol InputViewHolder {
    // get the input views for this inputviewholder
    func getInputViews() -> [BetterTextField]
    
    // determines if the fields are valid
    func areFieldsValid() ->  Bool
}
