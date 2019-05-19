//
//  LBLightTheme.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/19/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// This file exists solely as a means to separate this theme from the other themes.
// To use this theme, please use `LBTheme.light`.
// - seealso: LBTheme

extension LBTheme {

    /// The Light theme class. This conforms to LBThemeColorProvider to provide easy access to the colors available
    /// in the light theme of Lifting Buddy.
    ///
    /// This can be accessed via `UIColor.LBTheme.LBLightTheme`
    internal class LBLightTheme: ThemeColorProvider {

        /// The primary background color of Lifting Buddy. This color should be used for backgrounds.
        private static let primaryColorNormal = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1)

        /// Retrieves the style that navigation bars should use in the Light theme.
        ///
        /// - Returns: `UIBarStyle.blackOpaque`
        func getNavigationBarStyle() -> UIBarStyle {
            return .default
        }

        /// Used to retrieve the primary color for the Light theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The light theme's primary color of the input variant
        ///
        /// The primary color should be used for screen-filling backgrounds.
        public func getPrimaryColor(variant: ThemeColorVariant) -> UIColor {
            return LBLightTheme.primaryColorNormal
        }

        /// Used to retrieve the Light theme's primary accent color for this theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The Light theme's primary accent color of the input variant
        ///
        /// The primary accent color should be used in:
        /// 1. The navigation bar
        /// 1. UIButtons
        public func getPrimaryAccentColor(variant: ThemeColorVariant) -> UIColor {
            return LBLightTheme.primaryColorNormal
        }

        /// Used to retrieve the Light theme's primary accent color for this theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The Light theme's secondary accent color of the input variant
        ///
        /// The secondary accent color should be used in:
        /// 1. UIBarButtonItems
        /// 1. Toggle-able buttons (on/off, radio buttons)
        public func getSecondaryAccentColor(variant: ThemeColorVariant) -> UIColor {
            return LBLightTheme.primaryColorNormal
        }

        /// Initializes a Light ThemeColorProvider.
        public init() {}
    }
}
