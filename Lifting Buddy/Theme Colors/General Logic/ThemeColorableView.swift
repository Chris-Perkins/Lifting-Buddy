//
//  ThemeColorableView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/18/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A UIView-bound protocol that allows for the generalizing of UIView instances so that they can listen to changes in
/// theme.
///
/// Conforming to this protocol also provides `ThemeColorableView#addToThemeHost()` for use in adding colorable views
/// to the host.
public protocol ThemeColorableView where Self: UIView {

    /// Causes this view to recolor using the input ThemeColorProvider
    ///
    /// - Parameter colorProvider: The color provider that should be used to recolor this view.
    func color(using colorProvider: ThemeColorProvider)
}

// MARK: - ThemeColorableView provided functions

extension ThemeColorableView {

    /// Adds this ThemeColorableView to the ThemeHost.
    internal func addToThemeHost() {
        ThemeHost.shared.bindThemeColorableViewToTheme(self)
    }
}
