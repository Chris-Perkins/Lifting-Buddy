//
//  SessionViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/22/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

/// The View Controller where users can enter their workout information by using an input workout.
internal class SessionViewController: UIViewController {

    // TODO: Make this take in a workout that should be used for the session

    /// The label that is used for testing if the SessionViewController is working. This will be deleted once the
    /// SessionViewController is complete.
    private lazy var testLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.black
        label.numberOfLines = 2
        label.text = "test\nhello"
        return label
    }()

    /// Called when the view loads. Causes the views to layout themselves out via constraints.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviewsLayout()
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
        view.addSubview(testLabel)

        testLabel.copy(.width, of: view).withOffset(-16)
        testLabel.copy(.centerX, .centerY, of: view)
    }
}
