//
//  ThemeHost.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/18/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A color provider that lets a list of views listen to changes in the coloring theme. Access via `shared`.
///
/// This class is singleton-patterned, and no external initialization can be done. The class can be accessed via
/// `ThemeHost.shared`.
///
/// `ThemeColorableElement`s can use this class to listen to changes in color theme using
/// `ThemeHost#bindThemeColorableElementToTheme(_: ThemeColorableElement)`.
///
/// The theme can be changed by using `ThemeHost#activeColorTheme = <YourColorTheme>`.
open class ThemeHost {

    /// The singleton-accessible instance of the ThemeHost.
    public static var shared: ThemeHost = {
        return ThemeHost()
    }()

    /// The current active color theme of the application.
    ///
    /// onSet: remove the WeakContainers with now-`nil` references. Then, change all views to the active color theme.
    public var activeColorTheme: ThemeColorProvider {
        didSet {
            removeNilColorableViewListeners()
            changeAllBindedViewColorsToActiveTheme()
        }
    }

    /// The views that are colorable and are listening to changes in the color theme.
    ///
    /// - Note: While the container is of WeakContainers of UIView-type, they actually contain `ThemeColorableElement`s.
    /// This is because `ThemeHost#bindThemeColorableElementToTheme(_: ThemeColorableElement)` only accepts
    /// ThemeColorableElements.
    ///
    /// - Note: It is assumed that this array will never become too large (>1000 elements). If this occurs, then the
    /// performance of your application may suffer.
    private var themeColorableElementContainersBoundToTheme = [WeakContainer<AnyObject>]()

    /// Initializes a ThemeHost with the stored color theme.
    ///
    /// - Warning: Not yet complete; currently only uses the Light color theme.
    private init() {
        // TODO: Make this dynamic and stored.
        activeColorTheme = LBTheme.LBLightTheme()
    }

    /// Adds the input `ThemeColorableElement` to the views that listen to changes in the theme. Also calls
    /// `color(using: ThemeColorProvider)` to recolor the view to the current theme..
    ///
    /// - Parameter colorableView: The ThemeColorableElement
    public func bindThemeColorableElementToTheme(_ colorableView: ThemeColorableElement) {
        colorableView.color(using: activeColorTheme)

        themeColorableElementContainersBoundToTheme.append(WeakContainer(value: colorableView))
    }

    /// Removes any references to nil `ThemeColorableElement`s in `themeColorableElementContainersBoundToTheme`. Used to
    /// prevent the array from getting mis-managed and too large.
    private func removeNilColorableViewListeners() {
        themeColorableElementContainersBoundToTheme =
            themeColorableElementContainersBoundToTheme.filter { $0.value != nil }
    }

    /// Calls `ThemeColorableElement#color(using: ThemeColorProvider)` for all view containers bound to theme.
    private func changeAllBindedViewColorsToActiveTheme() {
        for viewContainer in themeColorableElementContainersBoundToTheme {
            guard let colorableViewsBoundToTheme = viewContainer.value as? ThemeColorableElement else {
                return
            }

            colorableViewsBoundToTheme.color(using: activeColorTheme)
        }
    }
}