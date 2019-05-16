//
//  LBNavigationController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/16/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import Foundation

/// A navigation controller that has a navigation bar that is styled in Lifting Buddy's manner.
public class LBNavigationController: UINavigationController {

    /// Called after the view for this ViewController loads. Also causes the navigation bar to style itself
    /// appropriately.
    override public func viewDidLoad() {
        super.viewDidLoad()

        stylizeNavigationBar(navigationBar)
    }

    /// Sylizes the navigation bar to Lifting Buddy standards.
    ///
    /// - Parameter navigationBar: The navigation bar that should be styled.
    ///
    /// Causes the following to happen:
    /// 1. The bar stylizes itself to be black-styled and opaque
    /// 1. If available, prefer large titles.
    private func stylizeNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.barStyle = .blackOpaque

        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
    }
}
