//
//  LBDarkTheme.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/19/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// This file exists solely as a means to separate this theme from the other themes.
// To use this theme, please use `LBTheme.dark`.
// - seealso: LBTheme

extension LBTheme {

    /// The Dark theme class. This conforms to LBThemeColorProvider to provide easy access to the colors available
    /// in the dark theme of Lifting Buddy.
    internal class LBDarkTheme: ThemeColorProvider {

        /// The primary background color of Lifting Buddy in the dark theme.
        private static let primaryColorNormal = UIColor(red: 33 / 255, green: 33 / 255, blue: 33 / 255, alpha: 1)

        /// The primary accent color of Dark Lifting Buddy in the dark theme.
        private static let primaryAccentColorNormal = UIColor(red: 61 / 255, green: 90 / 255, blue: 254 / 255, alpha: 1)

        /// The secondary accent color of Lifting Buddy in the dark theme.
        private static let secondaryAccentColorNormal =
            UIColor(red: 251 / 255, green: 192 / 255, blue: 45 / 255, alpha: 1)

        /// Retrieves the style that `UIBar`s should use in the Light theme.
        ///
        /// - Returns: `UIBarStyle.blackOpaque`
        func getUIBarStyle() -> UIBarStyle {
            return .blackOpaque
        }

        /// Used to retrieve the primary color for the Dark theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The Dark theme's primary color of the input variant
        ///
        /// The primary color should be used for screen-filling backgrounds.
        public func getPrimaryColor(variant: ThemeColorVariant) -> UIColor {
            return LBDarkTheme.primaryColorNormal
        }

        /// Used to retrieve the Dark theme's primary accent color for this theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The Dark theme's primary accent color of the input variant
        ///
        /// The primary accent color should be used in:
        /// 1. The navigation bar
        /// 1. UIButtons
        public func getPrimaryAccentColor(variant: ThemeColorVariant) -> UIColor {
            return LBDarkTheme.primaryAccentColorNormal
        }

        /// Used to retrieve the Dark theme's primary accent color for this theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The Dark theme's secondary accent color of the input variant
        ///
        /// The secondary accent color should be used in:
        /// 1. UIBarButtonItems
        /// 1. Toggle-able buttons (on/off, radio buttons)
        public func getSecondaryAccentColor(variant: ThemeColorVariant) -> UIColor {
            return LBDarkTheme.secondaryAccentColorNormal
        }

        /// Initializes a Dark ThemeColorProvider.
        public init() {}
    }
}
