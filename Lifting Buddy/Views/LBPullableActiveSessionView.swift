//
//  LBPullableActiveSessionView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/21/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

// MARK: - LBPullableActiveSessionView Main Declaration

/// A view that is used for displaying information about the active session.
///
/// - Note: This is currently just a skeleton, and needs to be filled in to be useful.
internal class LBPullableActiveSessionView: UIView {

    /// Initializes an LBPullableActiveSessionView instance with the provided frame. Adds this view to the theme.
    ///
    /// - Parameter frame: The frame to initialize with.
    override init(frame: CGRect) {
        super.init(frame: frame)

        addToThemeHost()
    }

    /// Initializes an LBPullableActiveSessionView instance with the provided NSCoder. Adds this view to the theme.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }
}

// MARK: - ThemeColorableElement Extension

extension LBPullableActiveSessionView: ThemeColorableElement {

    /// Colors the pullable active session view according to the current theme.
    ///
    /// - Parameter colorProvider: The color provider of the current theme
    ///
    /// Colors as following:
    /// * backgroundColor - Use the primary accent color's outer variant.
    func color(using colorProvider: ThemeColorProvider) {
        backgroundColor = colorProvider.getPrimaryAccentColor(variant: .outerElement)
    }
}
