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

        /// The primary color's outer variant in the light theme.
        private static let primaryColorOuter = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)

        /// The primary color's main variant in the light theme.
        private static let primaryColorMain = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)

        /// The primary color's inner variant in the light theme.
        private static let primaryColorInner = UIColor(red: 199 / 255, green: 199 / 255, blue: 199 / 255, alpha: 1)

        /// The primary accent color's outer variant in the light theme.
        private static let primaryAccentColorOuter =
            UIColor(red: 129 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1)

        /// The primary accent color's main variant in the light theme.
        private static let primaryAccentColorMain = UIColor(red: 61 / 255, green: 90 / 255, blue: 254 / 255, alpha: 1)

        /// The primary accent color's inner variant in the light theme.
        private static let primaryAccentColorInner =
            UIColor(red: 0 / 255, green: 49 / 255, blue: 202 / 255, alpha: 1)

        /// The secondary accent color's outer variant in the light theme.
        private static let secondaryAccentColorOuter =
            UIColor(red: 255 / 255, green: 242 / 255, blue: 99 / 255, alpha: 1)

        /// The secondary accent color's main variant in the light theme.
        private static let secondaryAccentColorMain =
            UIColor(red: 251 / 255, green: 192 / 255, blue: 45 / 255, alpha: 1)

        /// The secondary accent color's inner variant in the light theme.
        private static let secondaryAccentColorInner =
            UIColor(red: 196 / 255, green: 144 / 255, blue: 0 / 255, alpha: 1)

        /// Retrieves the style that `UIBar`s should use in the Light theme.
        ///
        /// - Returns: `UIBarStyle.blackOpaque`
        func getUIBarStyle() -> UIBarStyle {
            return .blackOpaque
        }

        /// Used to retrieve the primary color for the Light theme with an input color variant.
        ///
        /// - Parameter variant: The variant of the color to retrieve
        /// - Returns: The light theme's primary color of the input variant
        ///
        /// The primary color should be used for screen-filling backgrounds.
        public func getPrimaryColor(variant: ThemeColorVariant) -> UIColor {
            switch variant {
            case .outerElement:
                return LBLightTheme.primaryColorOuter
            case .mainElement:
                return LBLightTheme.primaryColorMain
            case .innerElement:
                return LBLightTheme.primaryColorInner
            }
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
            switch variant {
            case .outerElement:
                return LBLightTheme.primaryAccentColorOuter
            case .mainElement:
                return LBLightTheme.primaryAccentColorMain
            case .innerElement:
                return LBLightTheme.primaryAccentColorInner
            }
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
            switch variant {
            case .outerElement:
                return LBLightTheme.secondaryAccentColorOuter
            case .mainElement:
                return LBLightTheme.secondaryAccentColorMain
            case .innerElement:
                return LBLightTheme.secondaryAccentColorInner
            }
        }

        /// Initializes a Light ThemeColorProvider.
        public init() {}
    }
}
