//
//  ThemeColorable.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/18/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import Foundation

/// A UIView-bound protocol that allows for the generalizing of UIView instances so that they can listen to changes in
/// theme.
public protocol ThemeColorableView where Self: UIView {

    // This causes the view to re-color itself using the provided ThemeColorProvider.
    func color(using colorProvider: ThemeColorProvider)
}
