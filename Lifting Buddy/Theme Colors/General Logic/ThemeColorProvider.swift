//
//  ThemeColorProvider.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/16/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import Foundation

/// A color provider is used to provide the colors for a theme in Lifting Buddy.
public protocol ThemeColorProvider {

    /// Retrieves the style that navigation bars should use in this theme.
    ///
    /// - Returns: The navigation bar style for this theme
    func getNavigationBarStyle() -> UIBarStyle

    /// Used to retrieve the primary color for this theme with an input color variant.
    ///
    /// - Parameter variant: The variant of the color to retrieve
    /// - Returns: The primary color of the input variant
    ///
    /// The primary color should be used for screen-filling backgrounds.
    func getPrimaryColor(variant: ThemeColorVariant) -> UIColor

    /// Used to retrieve the primary accent color for this theme with an input color variant.
    ///
    /// - Parameter variant: The variant of the color to retrieve
    /// - Returns: The primary accent color of the input variant
    ///
    /// The primary accent color should be used in:
    /// 1. The navigation bar
    /// 1. UIButtons
    func getPrimaryAccentColor(variant: ThemeColorVariant) -> UIColor

    /// Used to retrieve the primary accent color for this theme with an input color variant.
    ///
    /// - Parameter variant: The variant of the color to retrieve
    /// - Returns: The secondary accent color of the input variant
    ///
    /// The secondary accent color should be used in:
    /// 1. UIBarButtonItems
    /// 1. Toggle-able buttons (on/off, radio buttons)
    func getSecondaryAccentColor(variant: ThemeColorVariant) -> UIColor
}
