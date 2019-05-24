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
internal class LBSessionViewController: UIViewController {

    // TODO: Make this take in a workout that should be used for the session

    /// The view which contains the button that can be closed.
    public private(set) lazy var closeContainerView = UIView(frame: .zero)

    /// The button that allows for this UIViewController to be dismissed.
    public private(set) lazy var closeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Close", for: .normal)
        return button
    }()

    /// The container view for all the content of this ViewController.
    private lazy var contentContainerView = UIView(frame: .zero)

    /// The label that is used for testing if the LBSessionViewController is working. This will be deleted once the
    /// LBSessionViewController is complete.
    private lazy var testLabel: UILabel = {
        let label = UILabel(frame: .zero)
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

        closeButton.addTarget(self, action: #selector(closeButtonPress(sender:)), for: .touchUpInside)
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
    /// 1. testLabel
    ///     * Fill the view horizontally with padding of 16
    ///     * Centered horizontally and vertically
    ///
    /// - Warning: This assumes `view` is non-nil.
    private func setupSubviewsLayout() {
        view.addSubview(closeContainerView)
        view.addSubview(contentContainerView)

        closeContainerView.addSubview(closeButton)
        contentContainerView.addSubview(testLabel)


        closeContainerView.cling(.top, to: topLayoutGuide, .bottom)
        closeContainerView.copy(.left, .right, of: view)

        contentContainerView.copy(.left, .right, of: view)
        contentContainerView.cling(.bottom, to: bottomLayoutGuide, .top)
        contentContainerView.cling(.top, to: closeContainerView, .bottom)

        closeButton.copy(.top, .left, .right, .bottom, of: closeContainerView)

        testLabel.copy(.width, of: contentContainerView).withOffsets(-16)
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
    /// * view.backgroundColor - Use the primary color's main variant
    func color(using colorProvider: ThemeColorProvider) {
        view.backgroundColor = colorProvider.getPrimaryColor(variant: .mainElement)
    }
}
