//
//  LBSessionViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/22/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

// MARK: - LBSessionViewController Main Declaration

/// The View Controller where users can enter their workout information by using an input workout.
final internal class LBSessionViewController: UIViewController {

    // TODO: Make this take in a workout that should be used for the session

    /// The header bar is a view that is used as the "header" for this View Controller.
    public private(set) lazy var headerBar = UIView()

    /// The headerInfoContainer is the container for all of the header bar's contents
    public private(set) lazy var headerInfoContainer = UIView()

    /// The title label for for the header info container. This will initialize the header title label with a preferred
    /// font of `.largeTitle` if available or `.title2` otherwise. Currently, this sets a dummy title of "Workout Name".
    /// Disables interaction to allow the user to drag down by pressing where the label is.
    public private(set) lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 11.0, *) {
            label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        } else {
            label.font = UIFont.preferredFont(forTextStyle: .title2)
        }
        label.isUserInteractionEnabled = false
        label.text = "Workout Name"
        // TODO: Use dynamic contrasting based on theme on recolor instead of doing this here :/
        label.textColor = UIColor.white
        return label
    }()

    /// The button that can be pressed by the user to allow the user to edit the currently active workout. The
    /// initialized button will have its title set.
    public private(set) lazy var editWorkoutButton: UIButton = {
        let button = UIButton()
        // Todo:
        button.setTitle("edit", for: .normal)
        return button
    }()

    /// The button that allows for this UIViewController to be dismissed. The initialized button will have it's title
    /// set and have a touch up inside event selector of `closeButtonPress(sender:)`
    public private(set) lazy var closeButton: UIButton = {
        let button = UIButton()
        // todo: make this an image that doesn't suck
        button.setTitle("v", for: .normal)
        button.addTarget(self, action: #selector(closeButtonPress(sender:)), for: .touchUpInside)
        return button
    }()

    /// The container view for all the content of this ViewController.
    private lazy var contentContainerView = UIView()

    /// The label that is used for testing if the LBSessionViewController is working. This will be deleted once the
    /// LBSessionViewController is complete.
    private lazy var testLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 2
        label.text = "test\nhello"
        label.textAlignment = .center
        return label
    }()

    /// Initializes an LBSessionViewController with the provided nibName or bundle. Both optional. Adds this
    /// LBSessionViewController to the theme host.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The nib name; optional
    ///   - nibBundleOrNil: The nib bundle; optional
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        addToThemeHost()
    }

    /// Initializes an LBSessionViewController from the provided NSCoder. Adds this LBSessionViewController to the theme
    /// host.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }

    /// Called when the view loads. Causes the views to layout themselves out via constraints.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviewsLayout()
    }

    /// Called when the close button is pressed. Causes the presentingViewController to disable interactive
    /// transitioning, dismisses self, then re-enables interactive transitioning again.
    ///
    /// - Parameter sender: The close button
    @objc func closeButtonPress(sender: UIButton) {
        let rootTransitionableViewController = presentingViewController as? InteractableTransitioniningViewController
        rootTransitionableViewController?.updateInteractiveTransitioningStatus(to: false)
        dismiss(animated: true) {
            rootTransitionableViewController?.updateInteractiveTransitioningStatus(to: true)
        }
    }

    /// Causes the views to lay themselves out accordingly.
    ///
    /// The layout is as follows:
    /// 1. Header Bar
    ///     * Copy the top, left, and right of the view (height is dynamic)
    ///     1. Header Info Container
    ///         * Copy the left, right of Header Bar with padding of 16
    ///         * Place 8 above the bottom of the Header Bar
    ///         * Place 8 below the top layout guide
    ///         * Height is dynamic
    ///         1. Close Button
    ///             * Copy the left, top, and bottom of Header Info Container
    ///             * Aspect ratio of 1:1
    ///         1. Header Title Label
    ///             * Copy the top, bottom of Header Info Container
    ///             * Place between the Edit Workoout Button and the Close Button with 4 padding
    ///         1. Edit Workout Button
    ///             * Copy the right, top, and bottom of Header Info Container
    ///             * Aspect ratio of 1:1
    /// 1. Content Container View
    ///     * Place below the header bar, fill the rest of the view
    ///     1. Test Label
    ///         * Center horizontally, vertically in the content container
    ///
    /// - Warning: This assumes `view` is non-nil.
    private func setupSubviewsLayout() {
        view.addSubview(headerBar)
        view.addSubview(contentContainerView)

        headerBar.addSubview(headerInfoContainer)
        contentContainerView.addSubview(testLabel)

        headerInfoContainer.addSubview(closeButton)
        headerInfoContainer.addSubview(headerTitleLabel)
        headerInfoContainer.addSubview(editWorkoutButton)

        headerBar.copy(.top, .left, .right, of: view)
        headerInfoContainer.cling(.top, to: topLayoutGuide, .bottom).withOffset(8)
        headerInfoContainer.copy(.left, of: headerBar).withOffset(16)
        headerInfoContainer.copy(.right, of: headerBar).withOffsets(-16)
        headerInfoContainer.copy(.bottom, of: headerBar).withOffsets(-8)

        closeButton.copy(.top, .left, .bottom, of: headerInfoContainer)
        closeButton.cling(.width, to: headerInfoContainer, .height)

        headerTitleLabel.copy(.top, .bottom, of: headerInfoContainer)
        headerTitleLabel.cling(.left, to: closeButton, .right).withOffset(4)
        headerTitleLabel.cling(.right, to: editWorkoutButton, .left).withOffset(4)

        editWorkoutButton.copy(.top, .bottom, .right, of: headerInfoContainer)
        editWorkoutButton.cling(.width, to: editWorkoutButton, .height)

        contentContainerView.copy(.left, .right, of: view)
        contentContainerView.cling(.bottom, to: bottomLayoutGuide, .top)
        contentContainerView.cling(.top, to: headerBar, .bottom)

        testLabel.copy(.centerX, .centerY, of: contentContainerView)
    }
}

// MARK: - ThemeColorableElement Extension

extension LBSessionViewController: ThemeColorableElement {

    /// Colors the tab bar such that it is Lifting Buddy style themed with the parameter theme.
    ///
    /// - Parameter colorProvider: The provider of the theme colors.
    ///
    /// Colors the elements as follows:
    /// * headerBar.backgroundColor - Use the primary accent color's main variant
    /// * view.backgroundColor - Use the primary color's main variant
    /// * closeButton - Use the secondary accent color's main variant
    /// * editWorkoutButton - Use the secondary accent color's main variant
    func color(using colorProvider: ThemeColorProvider) {
        headerBar.backgroundColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
        view.backgroundColor = colorProvider.getPrimaryColor(variant: .mainElement)
        closeButton.setTitleColor(colorProvider.getSecondaryAccentColor(variant: .mainElement), for: .normal)
        editWorkoutButton.setTitleColor(colorProvider.getSecondaryAccentColor(variant: .mainElement), for: .normal)
    }
}
