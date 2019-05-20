//
//  LBTabBarController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/20/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// MARK: - LBTabBarController Main Declaration

/// A Lifting-Buddy-styled UITabBarController. This means the tab bar will not be translucent, and the tab bar changes
/// based on the active theme.
///
/// The following will change and are not preserved from initialization:
/// * tabBar.barStyle
/// * tabBar.barTintColor
/// * tabBar.tintColor
/// * tabBar.isTranslucent
internal class LBTabBarController: UITabBarController {

    /// Whether or not the navigation bar is translucent.
    private static let isTranslucent = false

    /// Initializes an LBTabBarController with the provided nibName or bundle. Both optional. Adds this
    /// LBTabBarController to the theme host.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The nib name; optional
    ///   - nibBundleOrNil: The nib bundle; optional
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        addToThemeHost()
    }

    /// Initializes an LBTabBarController from the provided NSCoder. Adds this LBTabBarController to the theme host.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }

    /// Called when the view for the LBTabBarController loads. Causes the tab bar to turn off its translucency.
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isTranslucent = LBTabBarController.isTranslucent
    }

}

// MARK: - ThemeColorableElement Extension

extension LBTabBarController: ThemeColorableElement {

    /// Colors the tab bar such that it is Lifting Buddy style themed with the parameter theme.
    ///
    /// - Parameter colorProvider: The provider of the theme colors.
    ///
    /// The following will be changed using the provided theme:
    /// * tabBar.barStyle - Use the theme's bar style
    /// * tabBar.barTintColor - Use the theme's primary accent color (normal)
    /// * tabBar.tintColor - Use the theme's secondary accent color (normal)
    func color(using colorProvider: ThemeColorProvider) {
        tabBar.barStyle = colorProvider.getUIBarStyle()
        tabBar.barTintColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
        tabBar.unselectedItemTintColor = colorProvider.getPrimaryAccentColor(variant: .innerElement)
        tabBar.tintColor = colorProvider.getSecondaryAccentColor(variant: .mainElement)
    }
}
