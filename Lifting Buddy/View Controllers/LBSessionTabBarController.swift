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
final internal class LBSessionTabBarViewController: UIViewController {

    /// The height of the "active session view" in this View Controller.
    private static let activeSessionViewHeight: CGFloat = 50.0

    /// The active session view that should be displayed on top of the tab bar. Provides context about the current
    /// workout session.
    public private(set) lazy var activeSessionView = LBPullableActiveSessionView()

    /// The tab bar that should be displayed at the bottom of the view.
    public private(set) lazy var tabBar = LBTabBar()

    /// The view that should be used to display views from other `UIViewController`s.
    public private(set) lazy var containerView = UIView()

    /// The UIViewController that shows details about the active workout session.
    private lazy var sessionViewController = LBSessionViewController(nibName: nil, bundle: nil)

    /// The interaction handler for the transition between the pull up transition between this controller and the
    /// session view controller.
    private var presentSessionViewControllerInteractor: PullUpPresentViewControllerInteractiveTransition!

    /// The interaction handler for the transition to dismiss the session view controller.
    ///
    /// - Note: The interaction handler for this event is done here so as to prevent tightly-coupling the Session View
    /// Controller and the LBSessionTabBarController. This way, tightly-coupling is done only one way.
    private var dismissSessionViewControllerInteractor: PullDownDismissViewControllerInteractiveTransition!

    /// A variable that determines whether or not the transition for draggable views is enabled.
    private var isInteractivePlayerTransitioningEnabled = true

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

    /// Called when the view for this UIViewController. Does the following:
    /// * Causes all of the views to layout themselves via constraints
    /// * Sets up the transition between this View Controller and the session view controller
    /// * Assigns the tab bar delegate to `self`.
    /// * Adds the target to present the session button on the tap
    override internal func viewDidLoad() {
        super.viewDidLoad()

        activeSessionView.expandButton.addTarget(self,
                                                 action: #selector(sessionButtonTap(sender:)),
                                                 for: .touchUpInside)
        tabBar.delegate = self
        setupSubviewsLayout()
        setupSessionViewControllerTransitions()
    }

    /// Called whenever the button on the Pullable Active Session view is pressed. Disables the transition, presents
    /// the Session View Controller, then re-enables View Controller transitioning.
    ///
    /// - Parameter sender: The Pullable Active Session button.
    @objc func sessionButtonTap(sender: UIButton) {
        updateInteractiveTransitioningStatus(to: false)
        present(sessionViewController, animated: true) { [unowned self] in
            self.updateInteractiveTransitioningStatus(to: true)
        }
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

    /// Assigns the delegate for transitions accordingly. Initializes `presentSessionViewControllerInteractor` and
    /// `dismissSessionViewControllerInteractor`.
    private func setupSessionViewControllerTransitions() {
        presentSessionViewControllerInteractor =
            PullUpPresentViewControllerInteractiveTransition(fromViewController: self,
                                                             toViewController: sessionViewController,
                                                             pullableView: activeSessionView,
                                                             percentThresholdForCompletion: 0.2,
                                                             percentDifferenceForSnapCompletion: 0.03)
        dismissSessionViewControllerInteractor =
            PullDownDismissViewControllerInteractiveTransition(fromViewController: sessionViewController,
                                                               pullableView: sessionViewController.headerBar,
                                                               pullDownToView: activeSessionView,
                                                               percentThresholdForCompletion: 0.2,
                                                               percentDifferenceForSnapCompletion: 0.03)


        sessionViewController.transitioningDelegate = self
        sessionViewController.modalPresentationStyle = .fullScreen
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

        // Get the view associated with the view controller and constrain it to fill the view
        containerView.addSubview(tabBarItemViewControllerPair.1.view)
        tabBarItemViewControllerPair.1.view.copy(.top, .bottom, .left, .right, of: containerView)
    }
}

// MARK: - InteractableTransitioniningViewController Extension

extension LBSessionTabBarViewController: InteractableTransitioniningViewController {

    /// Updates the status of the View Controller and whether or not it can interactively transition via user-input.
    ///
    /// - Parameter canTransitionInteractively: Whether or not this UIViewController can interactively transition
    ///
    /// This specifically updates `isInteractivePlayerTransitioningEnabled`
    func updateInteractiveTransitioningStatus(to canTransitionInteractively: Bool) {
        isInteractivePlayerTransitioningEnabled = canTransitionInteractively
    }
}

//MARK: - UIViewControllerTransitioningDelegate Extension

extension LBSessionTabBarViewController: UIViewControllerTransitioningDelegate {

    /// Retrieves the present transition animator for the parameters. Only returns a non-`nil` value if `presented` is
    /// `sessionViewController`.
    ///
    /// - Parameters:
    ///   - presented: The View Controller that is being presented
    ///   - presenting: The view controller presenting the presented view controller
    ///   - source: The view controller whose `present` method was called.
    /// - Returns: An animator between the `sessionViewController` and this view controller if the
    /// presentedViewController is `sessionViewController`. Otherwise, `nil`.
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Make sure we're transitioning to the SessionViewController. If we're not, no animation occurs.
        if presented == sessionViewController {
            return LBSessionViewControllerPresentAnimator(initialY: view.frame.height - activeSessionView.frame.minY)
        }
        return nil
    }

    /// Retrieves the dismiss transition animator for the parameters. Only returns a non-`nil` value if `dismissed` is
    /// `sessionViewController`.
    ///
    /// - Parameter dismissed: The view controller that was dismissed.
    /// - Returns: An animator for the dismissal of `dismissed` if it is `sessionViewController`. `nil` otherwise.
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Make sure the dismissed view controller is the session view controller; otherwise, no animated transition
        // occurs.
        // Make sure we're transitioning to the SessionViewController. If we're not, no animation occurs.
        if dismissed == sessionViewController {
            return LBSessionViewControllerDismissAnimator(initialY: view.frame.height - activeSessionView.frame.minY)
        }
        return nil
    }

    /// Returns the present transition interaction handler.
    ///
    /// - Parameter animator: The animator being used for presenting transitions
    /// - Returns: `nil` if interactive transitioning is disabled; `presentSessionViewControllerInteractor` otherwise.
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard isInteractivePlayerTransitioningEnabled else { return nil }
            return presentSessionViewControllerInteractor
    }

    /// Returns the dismiss transition interaction handler.
    ///
    /// - Parameter animator: The animator being used for dismissal transitioned
    /// - Returns: `nil` if interactive transitioning is disabled; `dismissSessionViewControllerInteractor` otherwise.
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard isInteractivePlayerTransitioningEnabled else { return nil }
            return dismissSessionViewControllerInteractor
    }
}
