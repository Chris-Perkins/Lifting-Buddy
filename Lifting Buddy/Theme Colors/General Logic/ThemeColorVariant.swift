//
//  ThemeColorVariant.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/16/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// The different types of variants that each app theme Color can have.
///
/// - innerElement: The variant that should be used when the same color is used for an inner element.
/// - mainElement: The main variant of a color
/// - outerElement: The variant that should be used when the same color is used for an element outside the main element.
public enum ThemeColorVariant {
    case innerElement
    case mainElement
    case outerElement
}
