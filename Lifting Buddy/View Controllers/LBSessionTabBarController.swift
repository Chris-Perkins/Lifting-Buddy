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
/// 3. A container view that takes the view of the ViewController that is selected from the Tab Bar
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

    /// The view that should be used to display views from other `UIViewController`s.
    private lazy var containerView = UIView(frame: .zero)

    // TODO: On release, determine if performance needs to be sped up.
    /// The pairs of tab bar items and the view controllers associated with them.
    ///
    /// on value set:
    /// * Set the items of the tab bar to all of the tab bar items in the new value
    /// * If old value was empty and the new value isn't, then set the tab bar's selected item to the new value's first
    /// item
    private var tabBarItemViewControllerPairs = [(UITabBarItem, UIViewController)]() {
        didSet {
            tabBar.setItems(tabBarItemViewControllerPairs.map { $0.0 }, animated: true)

            if let tabBarItem = tabBarItemViewControllerPairs.first?.0, oldValue.isEmpty {
                tabBar.selectedItem = tabBarItem
                tabBar(tabBar, didSelect: tabBarItem)
            }
        }
    }

    /// Called when the view for this UIViewController. Causes all of the views to layout themselves via constraints.
    /// Assigns the tab bar delegate to `self`.
    override internal func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
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
    /// 1. Container View:
    ////    * Fill the remaining space
    private func setupSubviewsLayout() {
        view.addSubview(activeSessionView)
        view.addSubview(tabBar)
        view.addSubview(containerView)

        activeSessionView.cling(.bottom, to: tabBar, .top)
        activeSessionView.copy(.left, .right, of: tabBar)
        activeSessionView.setHeight(LBSessionTabBarViewController.activeSessionViewHeight)

        tabBar.cling(.bottom, to: bottomLayoutGuide, .top)
        tabBar.copy(.left, .right, of: view)

        containerView.copy(.top, .left, .right, of: view)
        containerView.cling(.bottom, to: activeSessionView, .top)
    }

    /// Adds a selectable tab with the specified item to view controller pair. The new item will be visible on the tab
    /// bar.
    ///
    /// - Parameters:
    ///   - displayItem: The item that should be used as the display for the UIViewController
    ///   - viewController: The View Controller associated with the object
    public func addTab(displayItem: UITabBarItem, viewController: UIViewController) {
        addChild(viewController)
        tabBarItemViewControllerPairs.append((displayItem, viewController))
    }
}

// MARK: - LBSessionTabBarViewController Extension

extension LBSessionTabBarViewController: UITabBarDelegate {

    /// Called when the tab bar has an item selected. Causes the container view to remove it's current subviews and adds
    /// the View Controller associated with the selected item's view to the container view.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar from which an item was selected
    ///   - item: The item that was selected in the tab bar
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        containerView.removeAllSubviews()

        guard let tabBarItemViewControllerPair = tabBarItemViewControllerPairs.first(where: { $0.0 == item }) else {
            return
        }

        containerView.addSubview(tabBarItemViewControllerPair.1.view)
        tabBarItemViewControllerPair.1.view.copy(.top, .bottom, .left, .right, of: containerView)
    }
}
