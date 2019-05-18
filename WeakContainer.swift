//
//  WeakContainer.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/18/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import Foundation

/// A class that contains a weak reference to a value.
///
/// This allows for a Collection of weak-references.
public struct WeakContainer<T: AnyObject> {

    /// A weak reference to the value being stored.
    weak private(set) var value: T?

    /// Initializes a WeakContainer with the input value.
    ///
    /// - Parameter value: The value to create a weak reference towards.
    public init(value: T) {
        self.value = value
    }
}
