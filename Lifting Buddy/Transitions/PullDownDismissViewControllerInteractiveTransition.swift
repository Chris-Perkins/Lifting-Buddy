//
//  PullDownDismissViewControllerInteractiveTransition.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/23/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A class that describes the progress for the amount of a View Controller transition as the amount that the user
/// has pulled a specified view up. Once the pull-up amount is over the specified threshold amount or the user snaps
/// the view up, the user can let go to fully complete the transition.
open class PullDownDismissViewControllerInteractiveTransition: UIPercentDrivenInteractiveTransition {

    // TODO: Implement sensitivity. It's 3 am and my mind can't handle the complexities of UX right now.
    /// The amount of difference that is required to change the stored direction that the the user is dragging in.
    ///
    /// E.g.: Consider the following scenario where transition is well above `percentThresholdForCompletion` and this
    /// value is 0.01:
    ///
    /// If the user drags 0.01 down then 0.005 up, then the view should be marked for dismissal since the user signaled
    /// that they do NOT want to open this VC.
    ///
    /// If, however, the user drags 0.01 down then 0.011 up, then this view should again re-mark itself for opening
    /// via `shouldComplete = true` since the threshold of change is above the value.
    private static let sensitivityForListeningToChangeInDirection: CGFloat = 0.02

    /// The View Controller that is being transitioned from.
    private var fromViewController: UIViewController

    /// The view that should be pulled up to transition.
    private var pullableView: UIView

    /// The view that should be pulled down to fully dismiss the controller.
    private var pullDownToView: UIView?

    /// The amount of progress that should be made to mark the transition as "completable on release"
    private var percentThresholdForCompletion: CGFloat

    /// The amount of difference between this and the last progress mark to "snap" the transition to "completable on
    /// release"
    private var percentDifferenceForSnapCompletion: CGFloat

    /// Whether or not the Transition should complete when the user ends their touches
    private var shouldComplete = false

    /// The last amount of progress that was made. Used to compare to the current progress to achieve "snapping".
    private var lastProgress: CGFloat?

    /// Initializes a PullUpPresentViewControllerInteractiveTransition instance with the provided parameters. Attaches
    /// a pan gesture recognizer to `pullableView` to keep track of pull progress.
    ///
    /// - Parameters:
    ///   - fromViewController: The View Controller that should be transitioned from
    ///   - pullableView: The view that should be pulled up in order to complete the transition.
    ///   - pullDownToView: The view that should be pulled down to
    ///   - percentThresholdForCompletion: The amount of progress that should be made by the user to mark the transition
    /// as "completable on release"
    ///   - percentDifferenceForSnapCompletion: The amount of progress that should be made between one progress mark and
    /// the previous to mark the transition as "completable as release". Acts as a "snap" factor.
    public init(fromViewController: UIViewController,
                pullableView: UIView,
                pullDownToView: UIView?,
                percentThresholdForCompletion: CGFloat,
                percentDifferenceForSnapCompletion: CGFloat) {
        self.fromViewController = fromViewController
        self.pullDownToView = pullDownToView
        self.pullableView = pullableView

        if percentDifferenceForSnapCompletion > 1 || percentDifferenceForSnapCompletion < 0
            || percentThresholdForCompletion > 1 || percentThresholdForCompletion < 0 {
            fatalError("Either/Both input percentThresholdForCompletion and percentDifferenceForSnapCompletion had"
                + "values not within a valid percentile range (0.0 -> 1.0). Please check your code.")
        }

        self.percentThresholdForCompletion = percentThresholdForCompletion
        self.percentDifferenceForSnapCompletion = percentDifferenceForSnapCompletion

        super.init()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(pan:)))
        self.pullableView.addGestureRecognizer(pan)
    }

    /// Called when `pullableView` is panned on. Uses the amount of panning that has occurred and the space below
    /// `pullableView` down to pullDownToView (if it exists, the height of the screen otherwise) as marks of the
    /// progress that this transition has made.
    ///
    /// - Parameter pan: The pan gesture recognizer
    ///
    /// Works by acting in the following ways:
    /// 1. Get progress of the pan gesture
    /// 1. Compare that progress to the previous progress
    ///     * If the progress went down, then the user is pulling down. Mark the transition as **not** completed on
    /// release.
    /// 1. If no action yet taken, check for the snap factor using the last progress count and the current progress.
    ///     * If the user "snapped" above the initialized threshold, `percentDifferenceForSnapCompletion`, then
    /// mark the transition as completed on release.
    /// 1. If no action yet taken, check if the progress is over our desired threshold.
    ///     * If the progress is over our threshold, `percentThresholdForCompletion`, mark it as complete.
    @objc private func onPan(pan: UIPanGestureRecognizer) {
        // Because the translation is done in a down-is-positive version, the amount that the user pulls up is the
        // negative amount of y translation.
        let pullUpAmount = pan.translation(in: pan.view?.superview).y

        // The amount of the screen that can be pulled-up from.
        // This is equal to all of the space below the pullableView to the pullDownToView variable or the height of the
        // screen (depending on whether pullDownToView is non-nil).
        let amountOfScreenToPullDownIn =
            (pullDownToView?.frame.minY ?? UIScreen.main.bounds.height) - pullableView.frame.maxY
        // The amount of progress the user made in dragging up is equal to the total amount they've pulled up over the
        // total amount that they CAN pull up.
        let rawProgress = pullUpAmount / amountOfScreenToPullDownIn
        // Clamp the progress between 0 and 1, because that's just how percentages should work.
        let clampedProgress = fmin(fmax(rawProgress, 0), 1)

        switch pan.state {
        case .began:
            fromViewController.dismiss(animated: true)
        case .changed:
            guard let lastProgress = lastProgress else {
                return
            }

            // Check 3 cases:
            // 1. Pull up - don't complete, as the user probably wants to keep the view open. (TODO: Sensitivity should
            /// go here)
            // 2. The user snaps the view up (TODO: Sensitivity should go here as well)
            // 3. The user drags the view up slowly
            //  * This will assign completion based on how much progress the user made in dragging up.
            if lastProgress > clampedProgress {
                shouldComplete = false
            } else if clampedProgress - lastProgress > percentDifferenceForSnapCompletion {
                shouldComplete = true
            } else {
                // Normal behavior
                shouldComplete = clampedProgress > percentThresholdForCompletion
            }

            update(clampedProgress)
        case .ended, .cancelled:
            if pan.state == .cancelled || shouldComplete == false {
                cancel()
            } else {
                finish()
            }
        default:
            break
        }

        lastProgress = clampedProgress
    }
}
