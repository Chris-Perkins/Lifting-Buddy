//
//  LBSessionTabBarViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/21/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

/// A ViewController that allows has three main components:
/// 1. A Tab Bar
/// 2. An "Active Session" Bar
/// 3. A container view
///
/// This acts as the main View Controller for Lifting Buddy, and should be used as the hub for all main View
/// Controllers.
internal class LBSessionTabBarViewController: UIViewController {

    /// The tab bar that should be displayed at the bottom of the view.
    private lazy var tabBar = LBTabBar(frame: .zero)

    /// Called when the view for this UIViewController. Causes all of the views to layout themselves via constraints.
    override internal func viewDidLoad() {
        super.viewDidLoad()

        setupSubviewsLayout()
    }

    /// Causes all of the views to constrain themselves accordingly.
    ///
    /// The layout of the views is as follows:
    /// 1. Tab Bar:
    ///     * Cling bottom to the bottom layout guide's top
    ///     * Copy the view's left and right constraints.
    private func setupSubviewsLayout() {
        view.addSubview(tabBar)

        tabBar.cling(.bottom, to: bottomLayoutGuide, .top)
        tabBar.copy(.left, .right, of: view)
    }
}
