//
//  SizeChangeOnPressViewContainer.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/8/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

/// A class that allows for a subview, `sizeChangingView`, to collapse whenever it is pressed. The amount of size change
/// that occurs is determined a multiplier that can be set: `sizeChangeAmount`.
@IBDesignable open class SizeChangeOnPressViewContainer: UIView {

    // MARK: - Properties

    /// The view that should change size when pressed.
    public let sizeChangingView = UIView()

    /// The amount that the view should contract.
    ///
    /// onSet: Update the contracted constraints multiplier
    ///
    /// Set to a value of 0-1 to contract, >1 to expand, otherwise invalid.
    @IBInspectable public var sizeChangeAmount: CGFloat = 0.85 {
        didSet {
            sizeChangeConstraints.withMultipliers(sizeChangeAmount)
        }
    }

    /// The amount of time that it should take for the animation of contraction to occur.
    @IBInspectable public var animationTime: CFTimeInterval = 0.15

    /// The constraints that should be activated when the contracting view should fill.
    private var fillConstraints: [NSLayoutConstraint]!

    /// The constraints that should be activated when the contracting view should contract.
    private var sizeChangeConstraints: [NSLayoutConstraint]!

    // MARK: - Life Cycle

    /// Initializes a ContractOnPressViewContainer instance with the provided frame. Constraints subviews and sets up
    /// the size changing event listeners.
    ///
    /// - Parameter frame: The frame to initialize with
    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupContractingViewPressObservers()
        setupSubviewsLayout()
    }

    /// Initializes a ContractOnPressViewContainer instance with the provided NSCoder. Constrains subviews and sets up
    /// the size changing event listeners.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupContractingViewPressObservers()
        setupSubviewsLayout()
    }

    // MARK: - Actions

    /// Called when the contracting view is tapped. Does nothing if the tapped view is **not** the contracting view.
    /// Causes the contracting view to contract when the event begins, and causes it to re-expand when the event ends.
    ///
    /// - Parameter gestureRecognizer: The gesture recognizer
    @objc func sizeChangingViewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view == sizeChangingView else { return }

        switch gestureRecognizer.state {
        case .began:
            // Press began; so activate the size changing constraints and animate changes
            self.fillConstraints.deactivateAllConstraints()
            self.sizeChangeConstraints.activateAllConstraints()
            UIView.animate(withDuration: animationTime,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            self.layoutIfNeeded()
            }, completion: nil)
        case .cancelled, .failed, .ended:
            // Press began; so activate the fill constraints and animate changes
            self.sizeChangeConstraints.deactivateAllConstraints()
            self.fillConstraints.activateAllConstraints()
            UIView.animate(withDuration: animationTime,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            self.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
    }

    // MARK: - Overrideable

    /// Lays out the subviews by adding them as subviews and constraining them.
    ///
    /// The layout of this view is as follows:
    /// 1. contractingView:
    ///     * Center vertically and horizontally
    ///     * Sets up two additional pairs of constraints
    ///         1. Expanded - Fill this view
    ///         1. Contracted - Copy the width of this view with the proper contraction
    open func setupSubviewsLayout() {
        addSubview(sizeChangingView)
        
        sizeChangingView.copy(.centerX, .centerY, of: self)

        sizeChangeConstraints = sizeChangingView.copy(.width, .height, of: self).withMultipliers(sizeChangeAmount)
        sizeChangeConstraints.deactivateAllConstraints()
        fillConstraints = sizeChangingView.copy(.width, .height, of: self)
    }

    // MARK: - Private

    /// Sets up the view press observers on the size changing view
    private func setupContractingViewPressObservers() {
        let observer = UILongPressGestureRecognizer(target: self, action: #selector(sizeChangingViewPressed(_:)))
        observer.minimumPressDuration = .zero
        sizeChangingView.isUserInteractionEnabled = true
        sizeChangingView.addGestureRecognizer(observer)
    }
}
