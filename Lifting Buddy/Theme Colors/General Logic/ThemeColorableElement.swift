//
//  ThemeColorableElement.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/18/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A UIView-bound protocol that allows for the generalizing of UIView instances so that they can listen to changes in
/// theme.
///
/// Conforming to this protocol also provides `ThemeColorableElement#addToThemeHost()` for use in adding colorable views
/// to the host.
public protocol ThemeColorableElement where Self: UIView {

    /// Causes this view to recolor using the input ThemeColorProvider
    ///
    /// - Parameter colorProvider: The color provider that should be used to recolor this view.
    func color(using colorProvider: ThemeColorProvider)
}

// MARK: - ThemeColorableElement provided functions

extension ThemeColorableElement {

    /// Adds this ThemeColorableElement to the ThemeHost.
    internal func addToThemeHost() {
        ThemeHost.shared.bindThemeColorableElementToTheme(self)
    }
}
