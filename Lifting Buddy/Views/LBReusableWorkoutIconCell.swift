//
//  LBReusableWorkoutIconCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/3/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

/// A cell that is used to display information about a workout.
internal class LBReusableWorkoutIconCell: UICollectionReusableView {

    /// The image that contains the fire graphic.
    private static let fireImage = UIImage(named: "Fire")

    /// Holds the values of the different layout-based values used in constraining the subviews of this view.
    private struct LayoutValues {

        /// The maximum multiplier for the relation between `streakImageView`'s and `self`'s height.
        static let streakImageViewSelfHeightMultiplier: CGFloat = 0.4

        /// The aspect ratio that the streakImageView should have.
        static let streakImageViewAspectRatio: CGFloat = 256 / 194

        /// Private initializer to disallow initialization.
        private init() {}
    }

    /// The label that displays the current streak count.
    public private(set) lazy var streakLabel: UILabel = UILabel()

    /// The image view that shows the flame image that signifies a streak.
    public private(set) lazy var streakImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = LBReusableWorkoutIconCell.fireImage
        return imageView
    }()

    /// The title that is used to display the name of the workout.
    public private(set) lazy var cellTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    /// The image view that gives the cell a picture-identifiable mode for displaying content. Scales to fit the image
    /// within this view while respecting aspect ratio.
    public private(set) lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The fake cell.
    ///
    /// This is "fake" because it is not the true cell, and only covers a portion of the space of the true space
    /// available through `self.`
    public let fakeCellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        return view
    }()

    /// Initializes a reusable workout icon cell with the provided frame. Also adds to the theme host and sets up the
    /// layout of this view.
    ///
    /// - Parameter frame: The frame to initialize with.
    override init(frame: CGRect) {
        super.init(frame: frame)

        addToThemeHost()
        setupSubViewsLayout()
    }

    /// Initializes a reusable workout icon cell with the provided decoder. Also adds to the theme host and sets up the
    /// layout of this view.
    ///
    /// - Parameter aDecoder: The Decoder to initialize with.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
        setupSubViewsLayout()
    }

    /// Lays out the subviews by adding them as subviews and constraining them.
    ///
    /// The layout of this view is as follows:
    /// 1. Streak Image View
    ///     * On top of the fake cell
    ///     * Takes up 40% of this view's height; aspect ratio is 256 / 194
    ///     1. Streak Label
    ///         * Center inside Streak Image View
    /// 1. Fake Cell View
    ///     * Cling to the bottom, left of `self`
    ///     * Cling `top` and `right` to the vertical and horizontal center of Stream Image View respectively
    ///     1. Cell Title
    ///         * Copy the bottom, left, and right constraints of `self`
    ///         * Height is automatic based on content
    ///     1. Cell Image
    ///         * Fill the rest of the space
    private func setupSubViewsLayout() {
        addSubview(fakeCellView)
        fakeCellView.addSubview(cellTitle)
        fakeCellView.addSubview(cellImageView)
        addSubview(streakImageView)
        streakImageView.addSubview(streakLabel)

        fakeCellView.copy(.bottom, .left, of: self)
        fakeCellView.cling(.top, to: streakImageView, .centerY)
        fakeCellView.cling(.right, to: streakImageView, .centerX)

        cellTitle.copy(.bottom, .left, .right, of: fakeCellView)

        cellImageView.copy(.top, .left, .right, of: fakeCellView)
        cellImageView.cling(.bottom, to: cellTitle, .top)

        streakImageView.copy(.height, of: self)
            .withMultipliers(LayoutValues.streakImageViewSelfHeightMultiplier)
        streakImageView.cling(.height, to: streakImageView, .width)
            .withMultiplier(LayoutValues.streakImageViewAspectRatio)
        streakImageView.copy(.top, .right, of: self)

        streakLabel.copy(.centerX, .centerY, of: streakImageView)
    }
}

// MARK: - ThemeColorableElement Extension

extension LBReusableWorkoutIconCell: ThemeColorableElement {

    /// Colors this view based on the current active color scheme.
    ///
    /// - Parameter colorProvider: The current active color theme.
    ///
    /// Colors as follows:
    /// * Stream Image - Use the secondary accent color's main variant.
    /// TODO: Streak Label - uses the B/W color that best constrasts with the secondary accent color's main variant.
    /// * Fake Cell View - Use the primary accent color's main variant
    /// TODO: * Cell Image - Uses the B/W color that best constrasts with the primary accent color's main variant.
    /// TODO: * Cell Title - Uses the color that constrats with the primary accent color's main variant.
    func color(using colorProvider: ThemeColorProvider) {
        streakImageView.tintColor = colorProvider.getSecondaryAccentColor(variant: .mainElement)
        fakeCellView.backgroundColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
    }
}
