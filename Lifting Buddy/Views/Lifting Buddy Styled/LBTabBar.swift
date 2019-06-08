//
//  LBTabBar.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/20/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// MARK: - LBTabBar Main Declaration

/// A Lifting-Buddy-styled UITabBar. This means the tab bar will not be translucent, and the tab bar changes based on
/// the active theme.
///
/// The following properties of the tab bar will change and are not preserved:
/// * barStyle
/// * barTintColor
/// * tintColor
/// * isTranslucent
internal class LBTabBar: UITabBar {

    /// Whether or not the navigation bar is translucent.
    private static let isTranslucent = false

    /// Initializes an LBTabBar with the provided frame. Adds the initialized instance to the theme host.
    ///
    /// - Parameter frame: The frame to initialize with
    override init(frame: CGRect) {
        super.init(frame: frame)

        addToThemeHost()
    }

    /// Initializes an LBTabBar with the provided NSCoder. Adds the initialized instance to the theme host.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }

    /// Styles this view and all subviews.
    ///
    /// Causes this tab bar to disable its translucency.
    override func layoutSubviews() {
        super.layoutSubviews()

        isTranslucent = LBTabBar.isTranslucent
    }
}

// MARK: - ThemeColorableElement Extension

extension LBTabBar: ThemeColorableElement {

    /// Colors the tab bar such that it is Lifting Buddy style themed with the parameter theme.
    ///
    /// - Parameter colorProvider: The provider of the theme colors.
    ///
    /// The following will be changed using the provided theme:
    /// * barStyle - Theme's bar style
    /// * barTintColor - Theme's primary accent color's main variant
    /// * unselectedItemTintColor - Theme's primary accent color's inner variant
    /// * tintColor - Theme's secondary accent color's main variant
    func color(using colorProvider: ThemeColorProvider) {
        barStyle = colorProvider.getUIBarStyle()
        barTintColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
        unselectedItemTintColor = colorProvider.getPrimaryAccentColor(variant: .innerElement)
        tintColor = colorProvider.getSecondaryAccentColor(variant: .mainElement)
    }
}
