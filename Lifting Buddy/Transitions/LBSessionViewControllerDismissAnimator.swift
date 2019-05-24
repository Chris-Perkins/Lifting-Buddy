//
//  LBSessionViewControllerDismissAnimator.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/23/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A View Controller Dismissal Animator. Acts as an an animator for transitions for a dismissal from a
/// `LBSessionViewController`.
internal class LBSessionViewControllerDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// The amount of time the transition should take to occur when the transition context is interactable.
    private static let timeToOpenOnInteractable: CFTimeInterval = 0.3

    /// The amount of time the transition should take to occur when the transition context is uninteractable.
    private static let timeToOpenOnUninteractable: CFTimeInterval = 0.2

    //MARK: - Properties
    var initialY: CGFloat

    /// Initializes an LBSessionViewControllerPresentAnimator which the input initialY value.
    ///
    /// - Parameter initialY: The value of the initial y value that the view should be shown as.
    internal init(initialY: CGFloat) {
        self.initialY = initialY
    }

    /// Animates the transition from a LBSessionViewControllerto a LBSessionTabBarViewController. Otherwise, does
    /// nothing.
    ///
    /// - Parameter transitionContext: The context that is used to determine the view controllers to transition between
    ///
    /// Animates the transition with the following logic:
    /// * Creates a fake tab bar from the LBSessionTabBarViewController; scrubs up as the user scrolls down
    /// * Scrubs the view of the Session View Controller down as the user scrubs downwards
    /// * Create a fake session view; scrubs along with the SessionViewController and fades in (alpha = 1)
    ///
    /// - Note: This does not handle well if the user changes the orientation of the screen while transitioning.
    /// However, different orientations are disabled in Lifting Buddy, so this is not an issue.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Determine if we can animate.
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let tabController = toVC as? LBSessionTabBarViewController,
            let sessionController = fromVC as? LBSessionViewController else {
                return
        }

        var fromRect = transitionContext.initialFrame(for: sessionController)
        fromRect.origin.y = fromRect.size.height - initialY

        // The view used to display the transition
        let container = transitionContext.containerView

        // Add all of the animatable views.
        container.addSubview(tabController.view)
        container.addSubview(sessionController.view)

        // The fake tab bar; slides down as the user drags upwards.
        let fakeTabBar = createFakeTabBar(fromLBSessionTabBarViewController: tabController)
        if let fakeTabBar = fakeTabBar {
            // Show the tab bar below the
            fakeTabBar.frame = CGRect(x: 0,
                                      y: container.frame.height,
                                      width: fakeTabBar.frame.width,
                                      height: fakeTabBar.frame.height)
            container.addSubview(fakeTabBar)
        }

        // The fake session view; placed at the top of the sessionController's view. Alpha set to 0, transitions to 1
        // as the user scrubs downwards.
        let fakeSessionView = tabController.activeSessionView.snapshotView(afterScreenUpdates: false)
        if let fakeSessionView = fakeSessionView {
            fakeSessionView.alpha = 0
            fakeSessionView.frame =
                CGRect(x: 0, y: 0, width: fakeSessionView.frame.width, height: fakeSessionView.frame.height)
            sessionController.view.addSubview(fakeSessionView)
        }

        // Animate the changes;
        // The fake session view transitions its alpha to 1; the tab bar scrubs on screen; the fromVC gets animated
        // downwards to hide from the view.
        let animOptions: UIView.AnimationOptions =
            transitionContext.isInteractive ? [UIView.AnimationOptions.curveLinear] : []
        let animationDuration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: animationDuration, delay: 0, options: animOptions, animations: {
            // Scrubs the view controller's frame upwards as the user scrubs upwards.
            fromVC.view.frame = fromRect
            if let fakeTabBar = fakeTabBar {
                // Animates the tab bar to go up from the bottom of the container when the user drags downwards
                fakeTabBar.frame = CGRect(x: 0,
                                          y: container.frame.height - fakeTabBar.frame.height,
                                          width: fakeTabBar.frame.width,
                                          height: fakeTabBar.frame.height)
            }
            // Fades the fake session view
            fakeSessionView?.alpha = 1
        }) { _ in
            fakeTabBar?.removeFromSuperview()
            fakeSessionView?.removeFromSuperview()

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    /// Retrieves the amount of time it should take for the transition to occur.
    ///
    /// - Parameter transitionContext: The transition to perform.
    /// - Returns: The amount of time it should take to perform a transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isInteractive ?? false
            ? LBSessionViewControllerDismissAnimator.timeToOpenOnInteractable
            : LBSessionViewControllerDismissAnimator.timeToOpenOnUninteractable
    }

    /// Creates a full tab bar clone including the space below the safe area guide.
    ///
    /// - Parameter fromLBSessionTabBarViewController: The view controller to create a tab bar clone from
    /// - Returns: A full tab bar clone as taken from a generic UIView.
    private func createFakeTabBar(fromLBSessionTabBarViewController: LBSessionTabBarViewController) -> UIView? {
        guard let fakeTabBar = fromLBSessionTabBarViewController.tabBar.snapshotView(afterScreenUpdates: false) else {
            return nil
        }

        let spaceBelowTabBar =
            fromLBSessionTabBarViewController.view.frame.height - fromLBSessionTabBarViewController.tabBar.frame.minY
        let fakeTabBarWithBottomHelperRect = CGRect(x: 0, y: 0, width: fakeTabBar.frame.width, height: spaceBelowTabBar)
        let fakeTabBarWithBottomSafeguard = UIView(frame: fakeTabBarWithBottomHelperRect)

        fakeTabBarWithBottomSafeguard.addSubview(fakeTabBar)
        // Copy the bar's tint color to keep up the illusion of a full fake tab bar
        fakeTabBarWithBottomSafeguard.backgroundColor = fromLBSessionTabBarViewController.tabBar.barTintColor
        return fakeTabBarWithBottomSafeguard
    }
}
