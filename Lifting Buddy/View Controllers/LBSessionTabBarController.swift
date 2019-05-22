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

    /// The height of the "active session view" in this View Controller.
    private static let activeSessionViewHeight: CGFloat = 50.0

    /// The active session view that should be displayed on top of the tab bar. Provides context about the current
    /// workout session.
    private lazy var activeSessionView = LBPullableActiveSessionView(frame: .zero)

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
    /// 1. Active Session View:
    ///     * Place on top of the tab bar, copy its width
    ///     * Set height to 50
    /// 1. Tab Bar:
    ///     * Display on top of `bottomLayoutGuide`
    ///     * Fill view horizontally
    private func setupSubviewsLayout() {
        view.addSubview(activeSessionView)
        view.addSubview(tabBar)

        activeSessionView.cling(.bottom, to: tabBar, .top)
        activeSessionView.copy(.left, .right, of: tabBar)
        activeSessionView.setHeight(LBSessionTabBarViewController.activeSessionViewHeight)

        tabBar.cling(.bottom, to: bottomLayoutGuide, .top)
        tabBar.copy(.left, .right, of: view)
    }
}
