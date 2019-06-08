//
//  LBNavigationBar.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/19/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// MARK: - LBNavigationBar main declaration

/// A Lifting-Buddy-styled UINavigationBar. Conforms to ThemeColorableElement so the navigation bar can change colors
/// based on the theme.
///
/// - Note: If used on the Storyboard, certain variables will be overriden. Those variables are:
/// * prefersLargeTitles
/// * isTranslucent
/// * barTintColor
/// * tintColor
/// * barStyle
internal class LBNavigationBar: UINavigationBar {

    /// Whether or not the navigation bar for this navigation controller prefers to use large titles.
    ///
    /// - Note: Only affects iOS 11.0 or newer.
    private static let prefersLargeTitles = true

    /// Whether or not the navigation bar is translucent.
    private static let isTranslucent = false

    /// Initializes a LBNavigationBar with the provided frame. Also adds the initialized LBNavigationBar to the theme
    /// host.
    ///
    /// - Parameter frame: The frame that the LBNavigationBar should take up.
    override internal init(frame: CGRect) {
        super.init(frame: frame)

        addToThemeHost()
    }

    /// Initializes a LBNavigationBar with the provided NSCoder. Also adds the initialized LBNavigationBar to the theme
    /// host.
    ///
    /// - Parameter coder: The NSCoder to initialize the LBNavigationBar with.
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }

    /// Layouts this navigation bar. For the LBNavigationBar, this causes the following:
    /// * Causes the navigation bar to prefer large titles if on iOS 11.0 or newer
    /// * Causes the navigation bar to not be translucent.
    override internal func layoutSubviews() {
        super.layoutSubviews()

        isTranslucent = LBNavigationBar.isTranslucent
        if #available(iOS 11.0, *) {
            prefersLargeTitles = LBNavigationBar.prefersLargeTitles
        }
    }
}

// MARK: - ThemeColorableElement Extension

extension LBNavigationBar: ThemeColorableElement {

    /// Causes this view to recolor using the input ThemeColorProvider
    ///
    /// - Parameter colorProvider: The color provider that should be used to recolor this view.
    ///
    /// Causes this view to recolor using the following methodologies:
    /// * Bar style - Use the theme's navigation bar style
    /// * Bar tint - Use the theme's primary accent color
    /// * Tint - Use the secondary accent color
    internal func color(using colorProvider: ThemeColorProvider) {
        barStyle = colorProvider.getUIBarStyle()
        barTintColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
        tintColor = colorProvider.getSecondaryAccentColor(variant: .mainElement)
    }
}
